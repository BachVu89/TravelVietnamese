#!/usr/bin/env python3
"""Structural source checks only; never substitutes for Unreal compile/cook/run."""
import ast
import hashlib
import sys
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'unreal/TravelVietnamese'

if '--fbx-readback' in sys.argv:
    import bpy
    import math
    root = PROJECT / 'ArtSource'
    report=json.loads((root/'asset-generation-report.json').read_text())
    for entry in report['assets']:
     bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
     bpy.ops.import_scene.fbx(filepath=str(root/entry['export']))
     objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
     assert len(objects)==1, (entry['name'],len(objects))
     o=objects[0];m=o.data;m.calc_loop_triangles()
     assert len(m.vertices)==entry['vertices'],entry['name']
     assert len(m.loop_triangles)==entry['triangles'],entry['name']
     assert len(m.uv_layers)>0 and all(math.isfinite(v) for p in m.vertices for v in p.co),entry['name']
     assert len(m.materials)==len(entry['material_slots']),entry['name']
     assert all(abs(a-b)<.001 for a,b in zip(o.dimensions,entry['dimensions_m'])),(entry['name'],tuple(o.dimensions))
     print('FBX_READBACK_PASS',entry['name'],len(m.vertices),len(m.loop_triangles),tuple(round(v,4) for v in o.dimensions))
    print('FBX_READBACK_ALL_PASS: 3 independent imports, geometry/UV/material-count/dimensions/finite checked; not UE import')
    raise SystemExit(0)

checks = 0

def check(condition, label):
    global checks
    if not condition:
        raise SystemExit('STATIC FAIL: ' + label)
    checks += 1

project = json.loads((PROJECT / 'TravelVietnamese.uproject').read_text())
check(project['EngineAssociation'] == '5.5', 'declared engine')
modules = project['Modules']
check(len(modules) == 1 and modules[0]['Name'] == 'TravelVietnamese' and modules[0]['Type'] == 'Runtime', 'runtime module')
for name in ('TravelVietnamese.Target.cs', 'TravelVietnameseEditor.Target.cs', 'TravelVietnamese/TravelVietnamese.Build.cs', 'TravelVietnamese/TravelVietnamese.cpp', 'TravelVietnamese/TravelPassEnvironment.h', 'TravelVietnamese/TravelPassEnvironment.cpp', 'TravelVietnamese/TravelPassGameMode.h', 'TravelVietnamese/TravelPassGameMode.cpp'):
    check((PROJECT / 'Source' / name).is_file(), 'source exists: ' + name)
for name in ('TravelExplorerCharacter.h', 'TravelExplorerCharacter.cpp'):
    check((PROJECT / 'Source/TravelVietnamese' / name).is_file(), 'grounded character source: ' + name)
character = (PROJECT / 'Source/TravelVietnamese/TravelExplorerCharacter.cpp').read_text()
header = (PROJECT / 'Source/TravelVietnamese/TravelExplorerCharacter.h').read_text()
mode = (PROJECT / 'Source/TravelVietnamese/TravelPassGameMode.cpp').read_text()
inputs = (PROJECT / 'Config/DefaultInput.ini').read_text()
check('public ACharacter' in header and 'ATravelExplorerCharacter::StaticClass()' in mode, 'grounded pawn declaration and GameMode reference')
for kind, binding in re.findall(r'Bind(Axis|Action)\(TEXT\("([^"]+)"\)', character):
    check(f'{kind}Name="{binding}"' in inputs, 'bound input has mapping: ' + binding)
check('StopMovementImmediately()' in character and 'ConsumeMovementInputVector()' in character and 'bHasSafeSpawn' in character, 'reset declares movement clearing and initialized-spawn guard (static only)')
report = json.loads((PROJECT / 'ArtSource/asset-generation-report.json').read_text())
check(len(report['assets']) == 3, 'three original mesh report entries')
for asset in report['assets']:
    export = PROJECT / 'ArtSource' / asset['export']
    check(export.is_file() and export.read_bytes().startswith(b'Kaydara FBX Binary'), 'binary FBX: ' + asset['name'])
    check(hashlib.sha256(export.read_bytes()).hexdigest() == asset['sha256'], 'FBX checksum: ' + asset['name'])
plugins = {p['Name']: p for p in project['Plugins']}
for name in ('PythonScriptPlugin', 'EditorScriptingUtilities'):
    check(plugins[name]['Enabled'] and plugins[name]['TargetAllowList'] == ['Editor'], 'editor-only plugin: ' + name)
check(plugins['ProceduralMeshComponent']['Enabled'], 'procedural mesh plugin')
for header in (PROJECT / 'Source').rglob('*.h'):
    includes = re.findall(r'^#include\s+"([^"]+)"', header.read_text(), re.M)
    check(includes[-1].endswith('.generated.h'), 'generated include last: ' + header.name)
for script in (PROJECT / 'Content/Python').glob('*.py'):
    ast.parse(script.read_text(), filename=str(script))
    check(True, 'Python AST: ' + script.name)
engine = (PROJECT / 'Config/DefaultEngine.ini').read_text()
game = (PROJECT / 'Config/DefaultGame.ini').read_text()
for setting in ('GameDefaultMap=/Game/Maps/PassPreview', 'EditorStartupMap=/Game/Maps/PassPreview', 'r.RayTracing=False', 'r.Nanite.ProjectEnabled=False', 'r.DynamicGlobalIlluminationMethod=0', 'r.ReflectionMethod=0', 'PackageName=com.travelvietnamese.unrealproof'):
    check(setting in engine, 'config: ' + setting)
check('MapsToCook=(FilePath="/Game/Maps/PassPreview")' in game, 'cook references preview map')
for document in ('unreal/README.md', 'docs/UNREAL_MIGRATION.md', 'docs/UNREAL_VALIDATION.md'):
    path = ROOT / document
    check(path.is_file(), 'document exists: ' + document)
    for target in re.findall(r'\]\(([^)]+)\)', path.read_text()):
        if not re.match(r'[a-zA-Z]+:', target) and not target.startswith('#'):
            check((path.parent / target.split('#')[0]).exists(), 'local link: ' + target)
print(f'STATIC PASS: {checks} structural checks; Python parsed, not executed with unreal.')
if not (PROJECT / 'Content/Maps/PassPreview.umap').exists():
    print('RUNTIME/COOK BLOCKED: PassPreview.umap absent; compile editor and run bootstrap before cook.')
print('NOT VERIFIED: UHT/UBT, UE Python APIs, shaders, collision, cook, offline runtime, mobile performance.')
