import ctypes as c, ctypes.util,json,argparse,hashlib,shutil
from pathlib import Path
parser=argparse.ArgumentParser(description="Join numeric 7z volumes and safely extract data files with system libarchive.")
parser.add_argument("--output",type=Path,required=True)
parser.add_argument("parts",nargs="+",type=Path)
args=parser.parse_args()
parts=sorted(args.parts,key=lambda p:int(p.suffix[1:]))
assert [int(p.suffix[1:]) for p in parts]==list(range(1,len(parts)+1)),"Missing/duplicate volume numbers"
assert len({p.name.rsplit(".",1)[0] for p in parts})==1,"Mixed archive families"
args.output.mkdir(parents=True,exist_ok=True)
joined=args.output/"joined.7z"
assert not joined.exists(),"Refusing to overwrite an existing join; choose a fresh output folder"
with joined.open("wb") as out:
 for part in parts:
  with part.open("rb") as f:shutil.copyfileobj(f,out)
manifest={"parts":[{"file":p.name,"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in parts],"archive_sha256":hashlib.sha256(joined.read_bytes()).hexdigest()}
(args.output/"parts.json").write_text(json.dumps(manifest,indent=2))
from pathlib import Path
lib=c.CDLL(ctypes.util.find_library('archive'))
lib.archive_read_new.restype=c.c_void_p
for name in ['archive_read_support_filter_all','archive_read_support_format_all','archive_read_free','archive_read_data_skip']:
 getattr(lib,name).argtypes=[c.c_void_p]
lib.archive_read_open_filename.argtypes=[c.c_void_p,c.c_char_p,c.c_size_t]
lib.archive_read_next_header.argtypes=[c.c_void_p,c.POINTER(c.c_void_p)]
lib.archive_entry_pathname.argtypes=[c.c_void_p];lib.archive_entry_pathname.restype=c.c_char_p
lib.archive_entry_size.argtypes=[c.c_void_p];lib.archive_entry_size.restype=c.c_int64
lib.archive_entry_filetype.argtypes=[c.c_void_p];lib.archive_entry_filetype.restype=c.c_uint
lib.archive_read_data.argtypes=[c.c_void_p,c.c_void_p,c.c_size_t];lib.archive_read_data.restype=c.c_ssize_t
lib.archive_error_string.argtypes=[c.c_void_p];lib.archive_error_string.restype=c.c_char_p
archive=lib.archive_read_new();lib.archive_read_support_filter_all(archive);lib.archive_read_support_format_all(archive)
root=args.output/'extracted';root.mkdir(exist_ok=True)
assert lib.archive_read_open_filename(archive,str(joined).encode(),10240)==0
entries=[];entry=c.c_void_p();buf=c.create_string_buffer(1024*1024)
try:
 while True:
  status=lib.archive_read_next_header(archive,c.byref(entry))
  if status==1:break
  assert status>=0,lib.archive_error_string(archive)
  name=lib.archive_entry_pathname(entry).decode('utf-8');p=Path(name);size=lib.archive_entry_size(entry);typ=lib.archive_entry_filetype(entry)
  assert not p.is_absolute() and '..' not in p.parts
  print(name,size,'type',oct(typ),flush=True)
  if typ==0o040000:(root/p).mkdir(parents=True,exist_ok=True);continue
  assert typ==0o100000,'No links or special entries'
  assert size<2*1024*1024*1024
  target=root/p;target.parent.mkdir(parents=True,exist_ok=True)
  with target.open('wb') as f:
   while True:
    n=lib.archive_read_data(archive,buf,len(buf))
    if n==0:break
    assert n>0,lib.archive_error_string(archive)
    f.write(buf.raw[:n])
  assert target.stat().st_size==size
  entries.append({'file':name,'bytes':size})
finally:lib.archive_read_free(archive)
(args.output/'extracted-files.json').write_text(json.dumps(entries,indent=2))
print('ARCHIVE_READ_COMPLETE',len(entries))
