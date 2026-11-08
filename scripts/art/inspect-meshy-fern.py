"""Read-only source FBX inspection. Run once in Blender; never modifies/reexports raw data.
blender --background --factory-startup --disable-autoexec --python scripts/art/inspect-meshy-fern.py
"""
import argparse, hashlib, json, sys, resource
from pathlib import Path
import bpy
from mathutils import Vector

parser = argparse.ArgumentParser()
parser.add_argument('--asset-dir', type=Path, default=Path('/tmp/meshy-fern-terraces/raw'))
parser.add_argument('--output', type=Path, default=Path('/tmp/meshy-fern-terraces-inspection'))
args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else [])
args.output.mkdir(parents=True, exist_ok=True)
fbxs = list(args.asset_dir.glob('*.fbx'))
if len(fbxs) != 1:
    raise RuntimeError('Expected exactly one source FBX')
fbx = fbxs[0]
def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()
report = {'blender': bpy.app.version_string, 'source_fbx': str(fbx), 'source_bytes': fbx.stat().st_size,
          'source_sha256': sha256(fbx), 'source_modified': False, 'meshes': [], 'renders': [],
          'note': 'Actual Blender CPU Cycles inspection, not Unity/HDRP/URP or mobile performance validation.'}
def save_report():
    (args.output / 'report.json').write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
print('FERN_IMPORT_START', str(fbx), flush=True)
bpy.ops.import_scene.fbx(filepath=str(fbx))
objects = list(bpy.context.scene.objects)
meshes = [obj for obj in objects if obj.type == 'MESH']
report['object_types'] = {kind: sum(obj.type == kind for obj in objects) for kind in sorted({obj.type for obj in objects})}
report['armatures'] = [obj.name for obj in objects if obj.type == 'ARMATURE']
report['actions'] = [action.name for action in bpy.data.actions]
report['materials_before_override'] = [{'name': mat.name, 'image_nodes': [node.image.filepath if node.image else None for node in mat.node_tree.nodes if node.type == 'TEX_IMAGE'] if mat.use_nodes else []} for mat in bpy.data.materials]
points = []
for obj in meshes:
    points.extend(obj.matrix_world @ Vector(corner) for corner in obj.bound_box)
    data = obj.data
    report['meshes'].append({'name': obj.name, 'vertices': len(data.vertices), 'polygons': len(data.polygons),
        'triangles': sum(len(poly.vertices) - 2 for poly in data.polygons), 'uv_layers': [uv.name for uv in data.uv_layers],
        'materials': [mat.name if mat else None for mat in data.materials], 'dimensions': list(obj.dimensions),
        'location': list(obj.location), 'rotation_euler': list(obj.rotation_euler), 'scale': list(obj.scale),
        'vertex_groups': [group.name for group in obj.vertex_groups], 'modifiers': [mod.type for mod in obj.modifiers],
        'shape_keys': [key.name for key in data.shape_keys.key_blocks] if data.shape_keys else []})
if not points:
    raise RuntimeError('No mesh geometry imported')
low = Vector(tuple(min(point[axis] for point in points) for axis in range(3)))
high = Vector(tuple(max(point[axis] for point in points) for axis in range(3)))
center = (low + high) / 2
size = high - low
report['world_bounds'] = {'min': list(low), 'max': list(high), 'dimensions': list(size), 'units': 'Blender importer world units; real dimensions/up-axis need visual verification'}
print('FERN_IMPORT_COMPLETE', json.dumps(report['meshes']), flush=True)
save_report()
material = bpy.data.materials.new('Fern_Inspection_Explicit_PNG_Maps')
material.use_nodes = True
nodes = material.node_tree.nodes
links = material.node_tree.links
principled = nodes.get('Principled BSDF')
for suffix, slot in [('_texture.png', 'Base Color'), ('_texture_metallic.png', 'Metallic'), ('_texture_roughness.png', 'Roughness'), ('_texture_normal.png', 'Normal')]:
    matches = [path for path in args.asset_dir.glob('*.png') if path.name.endswith(suffix)]
    if len(matches) != 1:
        raise RuntimeError('Missing/ambiguous review map: ' + suffix)
    path = matches[0]
    image = bpy.data.images.load(str(path))
    if slot != 'Base Color':
        image.colorspace_settings.name = 'Non-Color'
    node = nodes.new('ShaderNodeTexImage')
    node.image = image
    if slot == 'Normal':
        normal = nodes.new('ShaderNodeNormalMap')
        links.new(node.outputs['Color'], normal.inputs['Color'])
        links.new(normal.outputs['Normal'], principled.inputs['Normal'])
    else:
        links.new(node.outputs['Color'], principled.inputs[slot])
    report.setdefault('explicit_review_maps', []).append({'file': path.name, 'slot': slot, 'resolution': list(image.size), 'colorspace': image.colorspace_settings.name})
for obj in meshes:
    obj.data.materials.clear()
    obj.data.materials.append(material)
    for poly in obj.data.polygons:
        poly.material_index = 0
scene = bpy.context.scene
scene.render.threads_mode = 'FIXED'
scene.render.threads = 4
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 8
scene.cycles.use_denoising = False
scene.render.resolution_x = 700
scene.render.resolution_y = 700
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.world.color = (0.12, 0.12, 0.12)
span = max(size)
for direction, energy in [((2, -3, 4), 1300), ((-3, 2, 3), 900)]:
    bpy.ops.object.light_add(type='AREA', location=center + Vector(direction) * span)
    light = bpy.context.object
    light.data.energy = energy * span * span
    light.data.size = span * 3
    light.rotation_euler = (center - light.location).to_track_quat('-Z', 'Y').to_euler()
bpy.ops.object.camera_add()
camera = bpy.context.object
camera.data.type = 'ORTHO'
camera.data.ortho_scale = span * 1.45
camera.data.clip_end = max(1000, span * 20)
scene.camera = camera
report['render_settings'] = {'engine': 'CPU Cycles', 'samples': 8, 'resolution': [700, 700], 'denoising': False, 'threads_max': 4}
for name, direction in [('front', (1, -3, 1)), ('reverse', (-1, 3, 0.8)), ('top', (0, -0.01, 3))]:
    camera.location = center + Vector(direction).normalized() * span * 3
    camera.rotation_euler = (center - camera.location).to_track_quat('-Z', 'Y').to_euler()
    target = args.output / (name + '-blender.png')
    scene.render.filepath = str(target)
    bpy.ops.render.render(write_still=True)
    report['renders'].append({'file': target.name, 'camera_direction': list(direction)})
    save_report()
# Read-only source integrity verification after import and render.
report['source_sha256_after'] = sha256(fbx)
if report['source_sha256_after'] != report['source_sha256']:
    raise RuntimeError('Source file unexpectedly changed')
report['peak_process_rss_kib_linux'] = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
report['completed'] = True
save_report()
print('MESHY_FERN_INSPECTION_COMPLETE', flush=True)
