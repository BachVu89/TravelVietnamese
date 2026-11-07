"""Independent FBX readback under Blender, not Unity import or graphics acceptance.
blender --background --factory-startup --python-exit-code 1 --python FILE -- REPORT...
"""
import bpy
import hashlib
import json
import math
import sys
from pathlib import Path
reports=[Path(p).resolve() for p in sys.argv[sys.argv.index('--')+1:]]
checked=0
for path in reports:
    report=json.loads(path.read_text())
    for entry in report['assets']:
        export=path.parent/entry.get('file',entry.get('export',''))
        assert hashlib.sha256(export.read_bytes()).hexdigest()==entry['sha256'],export
        bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
        bpy.ops.import_scene.fbx(filepath=str(export))
        objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
        assert len(objects)==1,(entry['name'],'mesh count',len(objects))
        obj=objects[0];mesh=obj.data;mesh.calc_loop_triangles()
        assert len(mesh.vertices)==entry['vertices'],(entry['name'],'vertices',len(mesh.vertices))
        assert len(mesh.loop_triangles)==entry['triangles'],(entry['name'],'triangles',len(mesh.loop_triangles))
        assert len(mesh.uv_layers)>0,(entry['name'],'missing UV')
        assert all(math.isfinite(v) for p in mesh.vertices for v in p.co),(entry['name'],'nonfinite vertex')
        assert len(mesh.materials)==len(entry['material_slots']),(entry['name'],'slot count')
        assert all(abs(a-b)<.002 for a,b in zip(obj.dimensions,entry['dimensions_m'])),(entry['name'],'dimensions',tuple(obj.dimensions))
        checked+=1
        print('ART_READBACK_PASS',entry['name'],'vertices',len(mesh.vertices),'triangles',len(mesh.loop_triangles),'dimensions_m',tuple(round(v,4) for v in obj.dimensions),'slots',len(mesh.materials))
print('ART_READBACK_ALL_PASS',checked,'assets; Blender imports only, no Unity render/physics/scale confirmation')
