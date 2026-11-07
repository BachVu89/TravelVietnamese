"""Original deterministic Blender geometry; run with blender --background --python FILE.
No downloaded meshes, scans, textures, or third party asset inputs.
"""
import bpy, math, random, json, hashlib
from pathlib import Path
from mathutils import Vector
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'unreal/TravelVietnamese/ArtSource'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene.unit_settings.system='METRIC'; scene.unit_settings.scale_length=1.0
rng=random.Random(7112026)
def mat(name,color,rough=0.9):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1); p.inputs['Roughness'].default_value=rough
 return m
rock=mat('M_Cliff_DampStone',(0.24,0.26,0.22)); moss=mat('M_Cliff_Moss',(0.13,0.20,0.095))
fern=mat('M_Fern_Leaf',(0.085,0.24,0.065)); vein=mat('M_Plant_Stem',(0.18,0.26,0.07))
banana=mat('M_Banana_Leaf',(0.08,0.29,0.10)); banana_light=mat('M_Banana_LeafTip',(0.16,0.35,0.10))
stem=mat('M_Banana_Trunk',(0.28,0.32,0.12))
def mesh(name,verts,faces,mats,indices=None):
 data=bpy.data.meshes.new(name); data.from_pydata(verts,[],faces); data.update()
 obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj)
 for material in mats:data.materials.append(material)
 if indices:
  for p,i in zip(data.polygons,indices):p.material_index=i
 return obj
def uv(obj):
 bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
 bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.uv.smart_project(island_margin=0.025); bpy.ops.object.mode_set(mode='OBJECT')
def join(parts,name):
 bpy.ops.object.select_all(action='DESELECT')
 for o in parts:o.select_set(True)
 bpy.context.view_layer.objects.active=parts[0]; bpy.ops.object.join(); o=parts[0];o.name=name
 scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');uv(o);return o
def rod(name,a,b,r,material,segments=6):
 d=Vector(b)-Vector(a);bpy.ops.mesh.primitive_cone_add(vertices=segments,radius1=r,radius2=r*.6,depth=d.length,location=(Vector(a)+Vector(b))/2)
 o=bpy.context.object;o.name=name;o.rotation_euler=d.to_track_quat('Z','Y').to_euler();o.data.materials.append(material);return o
# Uneven layered cliff outcrop: nonuniform rings and silhouette, no image texture.
verts=[];faces=[];mi=[];n=14;levels=7
for j in range(levels):
 z=j*.48
 for i in range(n):
  a=2*math.pi*i/n;rr=1+rng.uniform(-.18,.18)+.10*math.sin(j*2+i)
  verts.append((math.cos(a)*rr*(1.55-.08*j),math.sin(a)*rr*(.85-.035*j),z+rng.uniform(-.13,.13)))
for j in range(levels-1):
 for i in range(n):
  a=j*n+i;b=j*n+(i+1)%n;c=(j+1)*n+(i+1)%n;d=(j+1)*n+i
  faces.extend([(a,b,c),(a,c,d)]);mi.extend([1 if rng.random()<.17 else 0]*2)
faces.extend([tuple(range(n-1,-1,-1)),tuple((levels-1)*n+i for i in range(n))]);mi.extend([0,1])
cliff=mesh('SM_CliffRock',verts,faces,[rock,moss],mi);uv(cliff)
# Fern: radial arching fronds, each has paired curved lance-shaped leaflets.
parts=[]
for f in range(9):
 angle=2*math.pi*f/9+rng.uniform(-.12,.12);length=rng.uniform(.72,1.08)
 def fp(t):return Vector((math.cos(angle)*length*t,math.sin(angle)*length*t,.08+.62*math.sin(t*math.pi*.8)))
 last=fp(0)
 for j in range(1,7):
  p=fp(j/6);parts.append(rod('FernRachis',last,p,.008,vein,5));last=p
 v=[];faces=[]
 for j in range(1,11):
  t=j/12;base=fp(t);width=.20*(1-t)*math.sin(t*math.pi)**.45
  forward=Vector((math.cos(angle),math.sin(angle),.2));side=Vector((-math.sin(angle),math.cos(angle),0))
  for sign in [-1,1]:
   b=len(v);mid=base+side*width*.58*sign+forward*.035;tip=base+side*width*sign+forward*.085;tip.z-=.035
   v.extend([base,mid-forward*.032,tip,mid+forward*.032+Vector((0,0,.025))]);faces.extend([(b,b+1,b+3),(b+1,b+2,b+3)])
 parts.append(mesh('FernLeaflets',v,faces,[fern]))
fern_obj=join(parts,'SM_Fern')
# Banana clump: tapered trunks and 18 broad curved leaf blades with center folds.
parts=[]
for k,(x,y,h) in enumerate([(0,0,2.1),(.45,.20,1.6),(-.35,.25,1.35)]):
 parts.append(rod('BananaPseudostem',(x,y,0),(x,y,h),.13,stem,9))
 for leaf in range(6):
  a=2*math.pi*leaf/6+k*.6;direction=Vector((math.cos(a),math.sin(a),0));side=Vector((-math.sin(a),math.cos(a),0));base=Vector((x,y,h-.10));length=rng.uniform(1.1,1.65)
  v=[];faces=[]
  for j in range(9):
   t=j/8;center=base+direction*(length*t);center.z+=.52*math.sin(t*math.pi)-.40*t*t
   w=.24*math.sin(math.pi*t)**.8
   for lane in [-1,0,1]:
    p=center+side*w*lane;p.z-=abs(lane)*.045;v.append(p)
  for j in range(8):
   for lane in range(2):
    a0=j*3+lane;faces.append((a0,a0+3,a0+4,a0+1))
  parts.append(mesh('BananaBlade',v,faces,[banana,banana_light],[leaf%2]*len(faces)))
  parts.append(rod('BananaPetiole',base,base+direction*.45+Vector((0,0,.35)),.018,vein,5))
banana_obj=join(parts,'SM_BananaClump')
assets=[cliff,fern_obj,banana_obj];records=[]
for obj in assets:
 # Ground the local mesh while retaining the base pivot at origin.
 minimum_z=min(v.co.z for v in obj.data.vertices)
 for vertex in obj.data.vertices: vertex.co.z-=minimum_z
 bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
 # Add a triangulate modifier so exported polygon/triangle accounting is explicit.
 tri=obj.modifiers.new('ExportTriangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=tri.name)
 bpy.ops.export_scene.fbx(filepath=str(OUT/(obj.name+'.fbx')),use_selection=True,object_types={'MESH'},apply_unit_scale=True,global_scale=1.0,axis_forward='-Y',axis_up='Z',bake_anim=False,add_leaf_bones=False,path_mode='AUTO')
 records.append({'name':obj.name,'export':obj.name+'.fbx','vertices':len(obj.data.vertices),'triangles':len(obj.data.polygons),'material_slots':[m.name for m in obj.data.materials],'uv_layers':[u.name for u in obj.data.uv_layers],'dimensions_m':[round(float(v),4) for v in obj.dimensions],'pivot':'base at local Z0','units':'metres; Blender FBX unit metadata exported','source':'original deterministic procedural geometry','seed':7112026,'sha256':hashlib.sha256((OUT/(obj.name+'.fbx')).read_bytes()).hexdigest()})
(OUT/'asset-generation-report.json').write_text(json.dumps({'generator':'scripts/art/create-pass-assets.py','blender_version':bpy.app.version_string,'assets':records},indent=2)+'\n')
# Preview layout only: exported meshes remain at origin in their own FBX files.
cliff.location=(-2.7,0,0);fern_obj.location=(0,-.65,0);banana_obj.location=(2.25,0,0)
ground=mat('PreviewGround',(.13,.16,.14));bpy.ops.mesh.primitive_plane_add(size=200);bpy.context.object.data.materials.append(ground)
scene.world.color=(.15,.15,.15)
for loc,energy,size in [((1,-4,7),1700,7),((-5,2,5),1200,5)]:
 bpy.ops.object.light_add(type='AREA',location=loc);l=bpy.context.object;l.data.energy=energy;l.data.shape='DISK';l.data.size=size;l.rotation_euler=(Vector((0,0,1))-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(7,-11,6));camera=bpy.context.object;camera.rotation_euler=(Vector((0,0,1.1))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=10.2;scene.camera=camera
scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=20;scene.cycles.use_denoising=False
scene.render.resolution_x=1100;scene.render.resolution_y=650;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/'docs/art/asset-preview.png')
# Label is actual mesh text in the render; clearly separates this from Unreal output.
bpy.ops.object.text_add(location=(-4,-2.1,.02));text=bpy.context.object;text.data.body='ORIGINAL PROCEDURAL ASSETS\nBLENDER PREVIEW - NOT UNREAL';text.data.size=.24;text.rotation_euler=(0,0,0);text.data.extrude=.002;text.data.materials.append(mat('PreviewLabel',(.75,.80,.72)))
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'TV_OriginalPassAssets.blend'))
bpy.ops.render.render(write_still=True)
print('ORIGINAL_ASSET_EXPORT_PASS',json.dumps(records))
