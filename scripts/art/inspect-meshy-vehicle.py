"""Inspect the supplied vehicle ZIP without modifying originals. Blender Python.
blender --background --python scripts/art/inspect-meshy-vehicle.py
"""
import bpy, zipfile, hashlib, json, math, argparse, sys, shutil
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser()
parser.add_argument('--source-zip',type=Path)
parser.add_argument('--fbx-name',help='Select an FBX filename explicitly when a folder has multiple LODs')
parser.add_argument('--asset-dir',type=Path,default=ROOT/'unity/TravelVietnamese/SourceFiles/Meshy/VehicleReference')
parser.add_argument('--output',type=Path,default=Path('/tmp/meshy-vehicle-inspection'))
args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
SOURCE=args.source_zip
OUT=args.output;OUT.mkdir(parents=True,exist_ok=True)
files=[]
if SOURCE:
 with zipfile.ZipFile(SOURCE) as z:
  for item in z.infolist():
   if item.is_dir():continue
   path=Path(item.filename)
   if path.is_absolute() or '..' in path.parts:raise RuntimeError('Unsafe ZIP path')
   if path.suffix.lower() not in ['.fbx','.png']:raise RuntimeError('Unexpected file type')
   dest=OUT/path.name
   with z.open(item) as f:dest.write_bytes(f.read())
   files.append({'name':path.name,'bytes':item.file_size,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()})
else:
 for path in sorted(args.asset_dir.rglob('*')):
  if path.is_file() and path.suffix.lower() in ['.fbx','.png']:
   dest=OUT/path.name
   if dest.resolve()!=path.resolve():shutil.copy2(path,dest)
   files.append({'name':path.name,'bytes':path.stat().st_size,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()})
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
fbx=OUT/args.fbx_name if args.fbx_name else sorted(OUT.glob('*.fbx'))[0]
bpy.ops.import_scene.fbx(filepath=str(fbx))
objects=list(bpy.context.scene.objects);meshes=[o for o in objects if o.type=='MESH']
report={'inspected_fbx':fbx.name,'source_zip':SOURCE.name if SOURCE else None,'zip_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest() if SOURCE else None,'asset_dir':str(args.asset_dir) if not SOURCE else None,'blender':bpy.app.version_string,'files':files,'meshes':[],'armatures':[o.name for o in objects if o.type=='ARMATURE'],'actions':[a.name for a in bpy.data.actions],'bones':{o.name:[b.name for b in o.data.bones] for o in objects if o.type=='ARMATURE'},'images_imported':[i.filepath for i in bpy.data.images],'materials_before_override':[]}
for material in bpy.data.materials:
 report['materials_before_override'].append({'name':material.name,'uses_nodes':material.use_nodes,'image_nodes':[n.image.filepath if n.image else None for n in material.node_tree.nodes if n.type=='TEX_IMAGE'] if material.use_nodes else []})
points=[]
for o in meshes:
 o.data.calc_loop_triangles();points.extend(o.matrix_world@Vector(c) for c in o.bound_box)
 report['meshes'].append({'name':o.name,'vertices':len(o.data.vertices),'polygons':len(o.data.polygons),'triangles':len(o.data.loop_triangles),'uv_layers':[u.name for u in o.data.uv_layers],'materials':[m.name for m in o.data.materials],'dimensions':[float(v) for v in o.dimensions],'location':[float(v) for v in o.location],'scale':[float(v) for v in o.scale],'rotation_euler':[float(v) for v in o.rotation_euler],'modifiers':[m.type for m in o.modifiers],'normal_attributes':[a.name for a in o.data.attributes if 'normal' in a.name.lower()],'vertex_groups':[v.name for v in o.vertex_groups],'shape_keys':[k.name for k in o.data.shape_keys.key_blocks] if o.data.shape_keys else [],'armature_modifier_targets':[m.object.name if m.object else None for m in o.modifiers if m.type=='ARMATURE']})
low=Vector(tuple(min(p[a] for p in points) for a in range(3)));high=Vector(tuple(max(p[a] for p in points) for a in range(3)));center=(low+high)/2;size=high-low
report['world_bounds']={'min':list(low),'max':list(high),'dimensions':list(size),'note':'Blender importer world units, not real object dimensions guaranteed'}
# Explicit map binding only for review. No source FBX/PNG edits or reexports.
m=bpy.data.materials.new('Inspection_PBR_ExplicitMaps');m.use_nodes=True;nodes=m.node_tree.nodes;links=m.node_tree.links;p=nodes.get('Principled BSDF')
for suffix,slot in [('_texture.png','Base Color'),('_texture_metallic.png','Metallic'),('_texture_roughness.png','Roughness'),('_texture_normal.png','Normal')]:
 path=next(v for v in OUT.glob('*.png') if v.name.endswith(suffix));image=bpy.data.images.load(str(path));tex=nodes.new('ShaderNodeTexImage');tex.image=image
 if slot!='Base Color':image.colorspace_settings.name='Non-Color'
 if slot=='Normal':
  norm=nodes.new('ShaderNodeNormalMap');links.new(tex.outputs['Color'],norm.inputs['Color']);links.new(norm.outputs['Normal'],p.inputs['Normal'])
 else:links.new(tex.outputs['Color'],p.inputs[slot])
 report.setdefault('explicit_review_maps',[]).append({'file':path.name,'slot':slot,'resolution':list(image.size),'colorspace':image.colorspace_settings.name})
for o in meshes:
 o.data.materials.clear();o.data.materials.append(m)
 for poly in o.data.polygons:poly.material_index=0
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=20;scene.cycles.use_denoising=False
scene.render.resolution_x=900;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.world.color=(.12,.12,.12)
height=max(size);target=center
for vec,energy in [((2,-3,4),1300),((-3,2,3),900)]:
 bpy.ops.object.light_add(type='AREA',location=center+Vector(vec)*height);light=bpy.context.object;light.data.energy=energy*height*height;light.data.size=height*3;light.rotation_euler=(target-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();camera=bpy.context.object;camera.data.type='ORTHO';camera.data.ortho_scale=height*1.45;scene.camera=camera
for name,direction in [('front',(1,-3,1)),('reverse',(-1,3,.8))]:
 camera.location=center+Vector(direction).normalized()*height*3;camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(OUT/(name+'-blender.png'));bpy.ops.render.render(write_still=True)
report['render_note']='Actual Blender CPU Cycles inspection using supplied maps; not Unity/Unreal, not device fidelity acceptance. Front/reverse are camera labels, not verified actual front orientation.'
(OUT/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('MESHY_VEHICLE_INSPECTION_PASS',json.dumps(report['meshes']))
