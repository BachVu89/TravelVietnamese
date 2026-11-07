#!/usr/bin/env python3
"""Structural source checks only; never substitutes for Unreal compile/cook/run."""
import ast
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'unreal/TravelVietnamese'
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
