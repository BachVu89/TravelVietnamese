#!/usr/bin/env python3
"""Fresh project integrity checks. Does not execute Unity, cook shaders or judge artwork."""
import json
import re
import shutil
import struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
checks=0

def need(value,reason):
    global checks
    if not value:raise SystemExit('VERIFY FAIL: '+reason)
    checks+=1

for directory in ('unity','unreal','game3d','src','art-source','artifacts'):
    need(not (ROOT/directory).exists(),'no legacy tree '+directory)
packages=json.loads((ROOT/'Packages/manifest.json').read_text())['dependencies']
need(packages.get('com.unity.render-pipelines.universal')=='17.0.3','URP version pinned')
need(not any(p in packages for p in ('com.unity.modules.inputlegacy','com.unity.render-pipelines.high-definition','com.unity.services.analytics')),'no invalid input module/HDRP/analytics')
version=(ROOT/'ProjectSettings/ProjectVersion.txt').read_text()
need('6000.0.' in version,'Unity 6.0 editor pin')
assets=ROOT/'Assets'
need(not list(assets.rglob('*.fbx')) and not list(assets.rglob('*.blend')),'fresh palette project without heavy imported models')
for path in assets.rglob('*'):
    if path.is_file():
        need(path.stat().st_size<8*1024*1024,'asset bounded below8MiB '+path.name)
        if path.suffix!='.meta':need(Path(str(path)+'.meta').is_file(),'stable metadata exists '+path.name)
guids={}
for meta in assets.rglob('*.meta'):
    metadata=meta.read_text()
    match=re.search(r'^guid:\s*([a-f0-9]{32})$',metadata,re.M)
    extension=meta.with_suffix('').suffix
    expected={'.png':'TextureImporter:', '.shader':'ShaderImporter:', '.mat':'NativeFormatImporter:', '.json':'TextScriptImporter:'}.get(extension)
    if expected:need(expected in metadata,'explicit Unity importer '+meta.name)
    need(bool(match),'metadata GUID '+str(meta.relative_to(ROOT)))
    if match:
        guid=match[1];need(guid not in guids,'unique GUID '+guid);guids[guid]=meta.with_suffix('')
scene_files=list(assets.rglob('*.unity'))
need(bool(scene_files),'saved entry scene present')
app_meta=(ROOT/'Assets/VietTrail/Presentation/TrailApp.cs.meta').read_text()
app_guid=re.search(r'^guid:\s*([a-f0-9]{32})$',app_meta,re.M)[1]
entry=(ROOT/'Assets/VietTrail/Scenes/Entry.unity').read_text()
need(bool(re.search(r'm_Script:.*guid: '+app_guid,entry)),'Entry script reference is TrailApp')
unknown=set()
for path in assets.rglob('*'):
    if not path.is_file() or path.suffix not in ('.unity','.mat','.asset'):continue
    for guid in re.findall(r'guid:\s*([a-f0-9]{32})',path.read_text()):
        if guid.startswith('00000000'):continue
        if guid in guids:need(guids[guid].exists(),'local reference target exists '+guids[guid].name)
        else:unknown.add(guid)
for source in assets.rglob('*.cs'):
    text=source.read_text()
    need(not re.search(r'UnityWebRequest|HttpClient|WebClient|System\.Net|UnityEngine\.Networking',text),'offline source '+source.name)
    if 'UnityEditor' in text:need('Editor' in source.parts,'Editor reference isolated '+source.name)
    for component in re.findall(r'class\s+(\w+)\s*:\s*MonoBehaviour',text):need(source.stem==component,'component file name '+component)
    if 'Core' in source.parts:need('UnityEngine' not in text,'pure Core '+source.name)
for png in (ROOT/'Assets/VietTrail/Resources/Theme/PainterlyPalette.png',):
    data=png.read_bytes();need(data[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',data[16:24])==(512,512),'512x512 palette '+png.name)
shader=(ROOT/'Assets/VietTrail/Rendering/PainterlyLit.shader').read_text()
need('Shader "VietTrail/Painterly Lit"' in shader and 'UniversalPipeline' in shader,'fresh painterly URP shader')
need('ShadowCaster' in shader and 'DepthOnly' in shader,'shadow and depth shader passes declared')
need(bool(list(assets.rglob('*.mat'))),'material asset exists')
material=(ROOT/'Assets/VietTrail/Resources/Theme/PainterlyWorld.mat').read_text()
for resource in ('Assets/VietTrail/Resources/Theme/PainterlyPalette.png','Assets/VietTrail/Rendering/PainterlyLit.shader'):
    guid=re.search(r'^guid:\s*([a-f0-9]{32})$',(ROOT/(resource+'.meta')).read_text(),re.M)[1]
    need(guid in material,'world material binds '+Path(resource).name)

print(f'VERIFY PASS: {checks} structural/reference checks. Not Unity compile, gameplay or graphics acceptance.')
if unknown:print('UNRESOLVED PACKAGE/ENGINE GUIDS (require Editor/package resolution): '+', '.join(sorted(unknown)))
print('Unity executable on PATH: '+str(shutil.which('Unity') or shutil.which('unity-editor') or 'not found'))
