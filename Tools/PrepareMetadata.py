#!/usr/bin/env python3
"""Create stable source metadata/minimal Entry and theme materials. Never overwrites user assets.
This is text generation, not a Unity import, package resolve or compile.
"""
import argparse
from pathlib import Path
import re
import uuid

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'Assets'
NAMESPACE = uuid.UUID('1c228450-c87a-5762-a99d-ebd64e3f5cf3')
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true', help='Validate presence only; do not write')
args = parser.parse_args()

def stable_guid(path):
    return uuid.uuid5(NAMESPACE, path.relative_to(ROOT).as_posix()).hex

def guid(path):
    meta = Path(str(path) + '.meta')
    if meta.exists():
        found = re.search(r'^guid:\s*([a-f0-9]{32})$', meta.read_text(), re.M)
        if not found:
            raise SystemExit('Invalid existing metadata (not replaced): ' + str(meta))
        return found.group(1)
    return stable_guid(path)

def create(path, text):
    if path.exists():
        return
    if args.check:
        raise SystemExit('Missing generated source: ' + str(path.relative_to(ROOT)))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('\n'.join(line.rstrip() for line in text.splitlines()) + '\n')

def metadata(path):
    meta = Path(str(path) + '.meta')
    if meta.exists():
        guid(path)
        return
    prefix = 'fileFormatVersion: 2\nguid: ' + stable_guid(path) + '\n'
    if path.is_dir():
        tail = 'folderAsset: yes\nDefaultImporter:\n  externalObjects: {}\n  userData: \n  assetBundleName: \n  assetBundleVariant: \n'
    elif path.suffix == '.cs':
        tail = 'MonoImporter:\n  externalObjects: {}\n  serializedVersion: 2\n  defaultReferences: []\n  executionOrder: 0\n  icon: {instanceID: 0}\n  userData: \n  assetBundleName: \n  assetBundleVariant: \n'
    elif path.suffix == '.png':
        tail = ('TextureImporter:\n  internalIDToNameTable: []\n  externalObjects: {}\n'
                '  serializedVersion: 13\n  mipmaps:\n    mipMapMode: 0\n    enableMipMap: 0\n    sRGBTexture: 1\n'
                '  isReadable: 0\n  textureFormat: 1\n  maxTextureSize: 512\n'
                '  textureSettings:\n    serializedVersion: 2\n    filterMode: 0\n    aniso: 1\n    mipBias: 0\n    wrapU: 1\n    wrapV: 1\n    wrapW: 1\n'
                '  nPOTScale: 0\n  compressionQuality: 50\n  spriteMode: 0\n  alphaUsage: 0\n  alphaIsTransparency: 0\n'
                '  textureType: 0\n  textureShape: 1\n  platformSettings:\n  - serializedVersion: 3\n'
                '    buildTarget: DefaultTexturePlatform\n    maxTextureSize: 512\n    resizeAlgorithm: 0\n    textureFormat: -1\n'
                '    textureCompression: 0\n    compressionQuality: 50\n    crunchedCompression: 0\n'
                '    allowsAlphaSplitting: 0\n    overridden: 0\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n')
    elif path.suffix == '.shader':
        tail = 'ShaderImporter:\n  externalObjects: {}\n  defaultTextures: []\n  nonModifiableTextures: []\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n'
    elif path.suffix == '.mat':
        tail = 'NativeFormatImporter:\n  externalObjects: {}\n  mainObjectFileID: 2100000\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n'
    elif path.suffix == '.json':
        tail = 'TextScriptImporter:\n  externalObjects: {}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n'
    else:
        tail = 'DefaultImporter:\n  externalObjects: {}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n'
    create(meta, prefix + tail)

app = ASSETS / 'VietTrail/Presentation/TrailApp.cs'
if not app.exists():
    raise SystemExit('TrailApp source is not present yet; refusing to create a dangling Entry scene.')
for path in sorted(ASSETS.rglob('*')):
    if path.suffix != '.meta': metadata(path)

scene = ASSETS / 'VietTrail/Scenes/Entry.unity'
app_guid = guid(app)
create(scene, f'''%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1 &1000
GameObject:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  serializedVersion: 6
  m_Component:
  - component: {{fileID: 1001}}
  - component: {{fileID: 1002}}
  m_Layer: 0
  m_Name: VietTrail App
  m_TagString: Untagged
  m_Icon: {{fileID: 0}}
  m_NavMeshLayer: 0
  m_StaticEditorFlags: 0
  m_IsActive: 1
--- !u!4 &1001
Transform:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: 1000}}
  serializedVersion: 2
  m_LocalRotation: {{x: 0, y: 0, z: 0, w: 1}}
  m_LocalPosition: {{x: 0, y: 0, z: 0}}
  m_LocalScale: {{x: 1, y: 1, z: 1}}
  m_ConstrainProportionsScale: 0
  m_Children: []
  m_Father: {{fileID: 0}}
  m_LocalEulerAnglesHint: {{x: 0, y: 0, z: 0}}
--- !u!114 &1002
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: 1000}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: 11500000, guid: {app_guid}, type: 3}}
  m_Name:
  m_EditorClassIdentifier:
''')

for name, shader_name in [('PainterlyWorld', 'PainterlyLit'), ('PainterlySky', 'PainterlySky')]:
    shader = ASSETS / ('VietTrail/Rendering/' + shader_name + '.shader')
    if not shader.exists(): raise SystemExit('Missing shader source ' + str(shader))
    mat = ASSETS / ('VietTrail/Resources/Theme/' + name + '.mat')
    texture = ASSETS / 'VietTrail/Resources/Theme/PainterlyPalette.png'
    texenvs = f'''    m_TexEnvs:
    - _Palette:
        m_Texture: {{fileID: 2800000, guid: {guid(texture)}, type: 3}}
        m_Scale: {{x: 1, y: 1}}
        m_Offset: {{x: 0, y: 0}}''' if name == 'PainterlyWorld' else '    m_TexEnvs: []'
    create(mat, f'''%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!21 &2100000
Material:
  serializedVersion: 8
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_Name: {name}
  m_Shader: {{fileID: 4800000, guid: {guid(shader)}, type: 3}}
  m_Parent: {{fileID: 0}}
  m_ModifiedSerializedProperties: 0
  m_ValidKeywords: []
  m_InvalidKeywords: []
  m_LightmapFlags: 4
  m_EnableInstancingVariants: 0
  m_DoubleSidedGI: 0
  m_CustomRenderQueue: -1
  stringTagMap: {{}}
  disabledShaderPasses: []
  m_LockedProperties:
  m_SavedProperties:
    serializedVersion: 3
{texenvs}
    m_Ints: []
    m_Floats: []
    m_Colors: []
  m_BuildTextureStacks: []
''')
for path in sorted(ASSETS.rglob('*')):
    if path.suffix != '.meta': metadata(path)
settings = ROOT / 'ProjectSettings/EditorBuildSettings.asset'
create(settings, f'''%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1045 &1
EditorBuildSettings:
  m_ObjectHideFlags: 0
  serializedVersion: 2
  m_Scenes:
  - enabled: 1
    path: Assets/VietTrail/Scenes/Entry.unity
    guid: {guid(scene)}
  m_configObjects: {{}}
''')
print('METADATA ' + ('CHECKED' if args.check else 'PREPARED') + ': stable GUIDs, minimal Entry, theme materials and BuildSettings. No Unity import/compile.')
