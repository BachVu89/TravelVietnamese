"""Blender FBX readback of actual user uploads; does not create a rig or Unity assets."""
import bpy
import json
import math
import sys
from pathlib import Path
for name in sys.argv[sys.argv.index('--')+1:]:
    file=Path(name).resolve()
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    for action in list(bpy.data.actions):bpy.data.actions.remove(action)
    bpy.ops.import_scene.fbx(filepath=str(file))
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    assert meshes,file
    entries=[]
    for obj in meshes:
        mesh=obj.data;mesh.calc_loop_triangles()
        assert mesh.uv_layers and all(math.isfinite(v) for p in mesh.vertices for v in p.co),file
        entries.append({'mesh':obj.name,'vertices':len(mesh.vertices),'triangles':len(mesh.loop_triangles),'uv_layers':len(mesh.uv_layers),'materials':len(mesh.materials),'vertex_groups':len(obj.vertex_groups),'armature_modifiers':sum(m.type=='ARMATURE' for m in obj.modifiers)})
    print('IMPORTED_FBX_READBACK',json.dumps({'file':file.name,'meshes':entries,'armatures':sum(o.type=='ARMATURE' for o in bpy.context.scene.objects),'actions':len(bpy.data.actions)},ensure_ascii=False))
print('READBACK_COMPLETE: Blender actual meshes only; not Unity import/render or animation retargeting')
