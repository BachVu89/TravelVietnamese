"""Read user-supplied PBR masks independently; no Unity/Shader execution."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageChops
ROOT=Path(__file__).resolve().parents[1]/'Assets/TravelVietnamese/Art/Imported/Meshy'
count=0
for folder in sorted(ROOT.iterdir()):
    if not (folder/'unity-mask-provenance.json').is_file():continue
    spec=json.loads((folder/'unity-mask-provenance.json').read_text())
    mask=Image.open(folder/spec['output']);assert mask.mode=='RGBA',folder
    metallic=Image.open(next(folder.glob('*_metallic.png'))).convert('L')
    roughness=Image.open(next(folder.glob('*_roughness.png'))).convert('L')
    assert mask.size==metallic.size==roughness.size,folder
    red,green,blue,alpha=mask.split()
    assert ImageChops.difference(red,metallic).getbbox() is None,(folder,'R not source metallic')
    assert green.getextrema()==(255,255),(folder,'G not constant255')
    assert blue.getextrema()==(128,128),(folder,'B not constant128')
    assert ImageChops.difference(alpha,ImageChops.invert(roughness)).getbbox() is None,(folder,'A not 255-roughness')
    assert hashlib.sha256((folder/spec['output']).read_bytes()).hexdigest()==spec['sha256'],folder
    count+=1
    print('MASK_PIXEL_PASS',folder.name,mask.size,'all pixels R=metallic G255 B128 A=255-roughness')
assert count>0,'no imported asset mask tested'
print('MASK_ALL_PASS',count,'assets; full image channel checks, not Unity shading')
