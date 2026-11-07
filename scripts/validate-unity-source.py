#!/usr/bin/env python3
"""Source/config consistency only. Does not compile Unity or run its engine."""
import json
import hashlib
import re
import shutil
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
check('m_EditorVersion: 6000.0.32f1' in (PROJECT/'ProjectSettings/ProjectVersion.txt').read_text(),'pinned editor')
domain=PROJECT/'Assets/TravelVietnamese/Runtime/PassRules.cs'
check('UnityEngine' not in domain.read_text() and 'UnityEditor' not in domain.read_text(),'Domain source independent engine')
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
project=ET.parse(PROJECT/'Tests/DomainHarness.csproj').getroot()
includes=[p.attrib['Include'] for p in project.findall('.//Compile')]
check(len(includes)==2,'domain harness includes actual domain and harness only')
for include in includes:check((PROJECT/'Tests'/include).is_file(),'harness compile source exists '+include)
check(not project.findall('.//PackageReference'),'no external harness packages')
for document in ('unity/README.md','docs/UNITY_MIGRATION.md','docs/UNITY_VALIDATION.md'):
    path=ROOT/document
    check(path.is_file(),'document '+document)
    for target in re.findall(r'\]\(([^)]+)\)',path.read_text()):
        if not re.match(r'[a-zA-Z]+:',target) and not target.startswith('#'):
            check((path.parent/target.split('#')[0]).exists(),'local link '+target)
hdrp=ROOT/'unity/TravelVietnamese-HDRP'
hdrp_dependencies=json.loads((hdrp/'Packages/manifest.json').read_text())['dependencies']
check(hdrp_dependencies.get('com.unity.render-pipelines.high-definition')=='17.0.3','HDRP desktop package pinned')
check('com.unity.render-pipelines.universal' not in hdrp_dependencies,'HDRP project excludes URP')
check({k:v for k,v in manifest['dependencies'].items() if k!='com.unity.render-pipelines.universal'}=={k:v for k,v in hdrp_dependencies.items() if k!='com.unity.render-pipelines.high-definition'},'only pipeline package differs between profiles')
check((hdrp/'ProjectSettings/ProjectVersion.txt').read_bytes()==(PROJECT/'ProjectSettings/ProjectVersion.txt').read_bytes(),'same editor pin across profiles')
for folder in ('Runtime','Art/Original'):
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
