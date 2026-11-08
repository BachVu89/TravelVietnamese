#!/usr/bin/env python3
"""Source/config consistency only. Does not compile Unity or run its engine."""
import json
import hashlib
import re
import shutil
import struct
from pathlib import Path
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT/'unity/TravelVietnamese'
count=0

def check(value,label):
    global count
    if not value: raise SystemExit('STATIC FAIL: '+label)
    count+=1

manifest=json.loads((PROJECT/'Packages/manifest.json').read_text())
check(manifest['dependencies']['com.unity.render-pipelines.universal']=='17.0.3','pinned URP')
check('com.unity.render-pipelines.high-definition' not in manifest['dependencies'],'no HDRP mobile dependency')
# Legacy Input is an Editor/player setting, not an installable built-in module.
invalid_modules={'com.unity.modules.inputlegacy','com.unity.modules.adaptiveperformance',
                 'com.unity.modules.physicscore2d','com.unity.modules.textgen'}
for project_name in ('TravelVietnamese','TravelVietnamese-HDRP'):
    deps=json.loads((ROOT/'unity'/project_name/'Packages/manifest.json').read_text())['dependencies']
    check(not invalid_modules.intersection(deps),'no invalid built-in module IDs: '+project_name)

check('m_EditorVersion: 6000.0.32f1' in (PROJECT/'ProjectSettings/ProjectVersion.txt').read_text(),'pinned editor')
domain=PROJECT/'Assets/TravelVietnamese/Runtime/PassRules.cs'
check('UnityEngine' not in domain.read_text() and 'UnityEditor' not in domain.read_text(),'Domain source independent engine')
check(not list((PROJECT/'Assets').rglob('*.blend')),'no Blender authoring source under mobile Assets')
for source in (PROJECT/'Assets').rglob('*.cs'):
    text=source.read_text()
    if 'UnityEditor' in text:check('Editor' in source.parts,'Editor references isolated: '+source.name)
    for component in re.findall(r'class\s+(\w+)\s*:\s*MonoBehaviour',text):
        check(source.stem==component,'MonoBehaviour class matches asset filename: '+component)
report=json.loads((ROOT/'unreal/TravelVietnamese/ArtSource/asset-generation-report.json').read_text())
for asset in report['assets']:
    export=PROJECT/'Assets/TravelVietnamese/Art/Original'/asset['export']
    check(export.is_file(),'original FBX exists '+asset['name'])
    check(hashlib.sha256(export.read_bytes()).hexdigest()==asset['sha256'],'copied FBX checksum '+asset['name'])
for relative in ('ForestSource/forest-generation-report.json','TravelSource/provenance.json'):
    report_path=PROJECT/'Assets/TravelVietnamese/Art'/relative
    art_report=json.loads(report_path.read_text())
    check(len(art_report['assets'])==3,'three assets in '+relative)
    for entry in art_report['assets']:
        export=report_path.parent/entry['file']
        check(export.is_file() and export.read_bytes().startswith(b'Kaydara FBX Binary'),'art export '+entry['name'])
        check(hashlib.sha256(export.read_bytes()).hexdigest()==entry['sha256'],'art checksum '+entry['name'])
imported=PROJECT/'Assets/TravelVietnamese/Art/Imported/Meshy'
catalog=json.loads((imported/'catalog.json').read_text())
check(catalog['schema_version']==1 and len(catalog['assets'])==6,'six imported asset families in catalog')
ids=[entry['id'] for entry in catalog['assets']]
check(len(ids)==len(set(ids)),'unique imported catalog IDs')
for entry in catalog['assets']:
    source=PROJECT/entry['source_folder']
    output=Path(entry['output_folder'])
    check(entry['source_folder'].startswith('Assets/TravelVietnamese/Art/Imported/Meshy/') and '..' not in Path(entry['source_folder']).parts,'catalog source contained '+entry['id'])
    check(str(output).startswith('Assets/TravelVietnamese/Generated/') and '..' not in output.parts,'catalog output contained '+entry['id'])
    if entry['available']:
        check((source/'unity-import.json').is_file(),'catalog import spec exists '+entry['id'])
        if entry['has_lod1']:check((source/'unity-import-lod1.json').is_file(),'catalog LOD spec exists '+entry['id'])
for folder in sorted(imported.iterdir()):
    if not folder.is_dir():continue
    check(all(p.stat().st_size<100*1024*1024 for p in folder.rglob('*') if p.is_file()),'all imported source files below 100MiB '+folder.name)
    provenance=json.loads((folder/'provenance.json').read_text())
    for entry in provenance['files']:
        raw=folder/entry['file']
        check(raw.is_file() and raw.stat().st_size==entry['bytes'],'imported source size '+folder.name+'/'+entry['file'])
        check(raw.stat().st_size<100*1024*1024,'source file under 100MiB '+raw.name)
        check(hashlib.sha256(raw.read_bytes()).hexdigest()==entry['sha256'],'imported source checksum '+raw.name)
    mask=json.loads((folder/'unity-mask-provenance.json').read_text())
    for entry in mask['inputs']+[{'file':mask['output'],'sha256':mask['sha256']}]:
        check(hashlib.sha256((folder/entry['file']).read_bytes()).hexdigest()==entry['sha256'],'imported mask checksum '+folder.name+'/'+entry['file'])
    if (folder/'lod-provenance.json').is_file():
        lods=json.loads((folder/'lod-provenance.json').read_text())
        check(lods['rigging_performed'] is False,'LOD processing does not claim rigging '+folder.name)
        check(not (folder/lods['source_fbx']).exists(),'heavy original retained outside Unity Assets '+folder.name)
        for lod in lods['lods']:
            check(hashlib.sha256((folder/lod['file']).read_bytes()).hexdigest()==lod['sha256'],'derived LOD checksum '+lod['file'])
    for import_spec in folder.glob('unity-import*.json'):
        references=json.loads(import_spec.read_text())
        for key in ('fbx','base_color','normal','mask'):
            check(Path(references[key]).name==references[key] and (folder/references[key]).is_file(),'safe import variant '+folder.name+'/'+import_spec.name+'/'+key)
    spec=json.loads((folder/'unity-import.json').read_text())
    for key in ('fbx','base_color','normal','mask'):
        check(Path(spec[key]).name==spec[key] and (folder/spec[key]).is_file(),'safe existing import reference '+folder.name+'/'+key)
maps=PROJECT/'Assets/TravelVietnamese/Art/SurfaceMaps'
provenance=json.loads((maps/'provenance.json').read_text())
check(provenance['resolution']==512 and len(provenance['maps'])==9,'nine 512 original maps provenance')
check({entry['file'] for entry in provenance['maps']}=={f'{surface}_{kind}.png' for surface in ('Road','Rock','Soil') for kind in ('BaseColor','Normal','Mask')},'complete PBR map family')
for entry in provenance['maps']:
    data=(maps/entry['file']).read_bytes()
    check(hashlib.sha256(data).hexdigest()==entry['sha256'],'surface map hash '+entry['file'])
    check(data[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',data[16:24])==(512,512),'PNG size '+entry['file'])
project=ET.parse(PROJECT/'Tests/DomainHarness.csproj').getroot()
includes=[p.attrib['Include'] for p in project.findall('.//Compile')]
check(set(includes)=={'../Assets/TravelVietnamese/Runtime/PassRules.cs','../Assets/TravelVietnamese/Runtime/CameraOcclusionRules.cs','DomainHarness.cs'},'domain harness includes actual pure domain sources and harness only')
for include in includes:check((PROJECT/'Tests'/include).is_file(),'harness compile source exists '+include)
check(not project.findall('.//PackageReference'),'no external harness packages')
for document in ('unity/README.md','docs/UNITY_MIGRATION.md','docs/UNITY_VALIDATION.md'):
    path=ROOT/document
    check(path.is_file(),'document '+document)
    for target in re.findall(r'\]\(([^)]+)\)',path.read_text()):
        if not re.match(r'[a-zA-Z]+:',target) and not target.startswith('#'):
            check((path.parent/target.split('#')[0]).exists(),'local link '+target)
hdrp=ROOT/'unity/TravelVietnamese-HDRP'
check(not list((hdrp/'Assets').rglob('*.blend')),'no Blender authoring source under HDRP Assets')
hdrp_dependencies=json.loads((hdrp/'Packages/manifest.json').read_text())['dependencies']
check(hdrp_dependencies.get('com.unity.render-pipelines.high-definition')=='17.0.3','HDRP desktop package pinned')
check('com.unity.render-pipelines.universal' not in hdrp_dependencies,'HDRP project excludes URP')
check({k:v for k,v in manifest['dependencies'].items() if k!='com.unity.render-pipelines.universal'}=={k:v for k,v in hdrp_dependencies.items() if k!='com.unity.render-pipelines.high-definition'},'only pipeline package differs between profiles')
check((hdrp/'ProjectSettings/ProjectVersion.txt').read_bytes()==(PROJECT/'ProjectSettings/ProjectVersion.txt').read_bytes(),'same editor pin across profiles')
for folder in ('Runtime','Art/Original','Art/SurfaceMaps','Art/ForestSource','Art/TravelSource','Art/Imported'):
    relative=Path('Assets/TravelVietnamese')/folder
    mobile={f.relative_to(PROJECT/relative):f for f in (PROJECT/relative).rglob('*') if f.is_file() and f.suffix!='.meta'}
    desktop={f.relative_to(hdrp/relative):f for f in (hdrp/relative).rglob('*') if f.is_file() and f.suffix!='.meta'}
    check(mobile.keys()==desktop.keys(),'shared source file set '+folder)
    for name,path in mobile.items():check(path.read_bytes()==desktop[name].read_bytes(),'shared binary parity '+str(name))
for profile,pipeline,forbidden in ((PROJECT,'Universal','HighDefinition'),(hdrp,'HighDefinition','Universal')):
    for source in (profile/'Assets').rglob('*.cs'):
        text=source.read_text()
        check('UnityEngine.Rendering.'+forbidden+';' not in text,'pipeline source isolation '+profile.name+'/'+source.name)
        if 'UnityEditor' in text:check('Editor' in source.parts,'Editor isolation '+profile.name+'/'+source.name)
desktop_setup=(hdrp/'Assets/TravelVietnamese/Editor/DesktopPassSetup.cs').read_text()
check('HDRenderPipelineAsset' in desktop_setup and 'HDRP Wizard' in desktop_setup,'desktop pipeline setup guard')
check('BuildAndroid(' not in desktop_setup,'no HDRP Android builder')
print(f'STATIC PASS: {count} checks; no Unity compilation, scene generation or engine execution.')
if not list((PROJECT/'Assets').rglob('*.unity')):print('EDITOR GATE: no saved Unity scene yet; run bootstrap in licensed matching Editor.')
print('Editor on PATH: '+str(shutil.which('Unity') or shutil.which('unity-editor') or 'not found'))
