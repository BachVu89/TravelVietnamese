"""Blender: derive UV-preserving static LODs from user-supplied Courier; never modify source."""
import bpy,json,hashlib,sys,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--source-dir',type=Path,required=True)
p.add_argument('--output-dir',type=Path,default=ROOT/'unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/Courier')
p.add_argument('--asset-prefix',default='Courier')
p.add_argument('--lod0-triangles',type=int,default=100000)
p.add_argument('--lod1-triangles',type=int,default=30000)
a=p.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
source=next(a.source_dir.rglob('*.fbx'))
out=a.output_dir;out.mkdir(parents=True,exist_ok=True)
assert a.lod0_triangles>=a.lod1_triangles>0
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.fbx(filepath=str(source));original=[o for o in bpy.context.scene.objects if o.type=='MESH']
assert not any(o.type=='ARMATURE' for o in bpy.context.scene.objects),'Rigged source requires a dedicated pipeline'
assert len(original)==1,'Review multi-object export manually'
obj=original[0];obj.data.calc_loop_triangles();count=len(obj.data.loop_triangles)
records=[]
previous_mesh=None
for name,target in [(a.asset_prefix+'_LOD0',a.lod0_triangles),(a.asset_prefix+'_LOD1',a.lod1_triangles)]:
 duplicate=obj.copy();duplicate.data=(obj.data if previous_mesh is None else previous_mesh).copy();bpy.context.collection.objects.link(duplicate);duplicate.name=name
 bpy.ops.object.select_all(action='DESELECT');duplicate.select_set(True);bpy.context.view_layer.objects.active=duplicate
 duplicate.data.calc_loop_triangles();base_count=len(duplicate.data.loop_triangles)
 modifier=duplicate.modifiers.new('Derived static LOD, original retained','DECIMATE');modifier.ratio=min(1,target/base_count);modifier.use_collapse_triangulate=True
 bpy.ops.object.modifier_apply(modifier=modifier.name)
 duplicate.data.calc_loop_triangles();path=out/(name+'.fbx')
 bpy.ops.export_scene.fbx(filepath=str(path),use_selection=True,object_types={'MESH'},apply_unit_scale=True,axis_forward='-Z',axis_up='Y',bake_anim=False,add_leaf_bones=False,path_mode='STRIP',embed_textures=False)
 records.append({'file':path.name,'vertices':len(duplicate.data.vertices),'triangles':len(duplicate.data.loop_triangles),'uv_layers':[x.name for x in duplicate.data.uv_layers],'materials':[x.name for x in duplicate.data.materials], 'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
 if previous_mesh is None:previous_mesh=duplicate.data.copy()
 reduced_data=duplicate.data
 bpy.data.objects.remove(duplicate,do_unlink=True)
 if reduced_data.users==0:bpy.data.meshes.remove(reduced_data)
report={'pipeline_version':2,'lod1_derived_from':'LOD0','source':'User-provided Meshy static source, original retained in workspace; no rigging/animation performed','source_fbx':source.name,'source_bytes':source.stat().st_size,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_triangles':count,'generator':'scripts/art/prepare-meshy-courier.py','blender':bpy.app.version_string,'lods':records,'rigging_performed':False,'unity_render_or_mobile_verified':False}
(out/'lod-provenance.json').write_text(json.dumps(report,indent=2)+'\n')
print('COURIER_LODS_CREATED',json.dumps(records))
