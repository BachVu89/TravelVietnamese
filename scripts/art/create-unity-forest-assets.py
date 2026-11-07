"""Original seed-based branching trees; Blender background, no external inputs."""
import bpy, math, random, json, hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'unity/TravelVietnamese/Assets/TravelVietnamese/Art/ForestSource';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene;scene.unit_settings.system='METRIC';scene.unit_settings.scale_length=1
rng=random.Random(71130)
def material(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=.94
 return m
mats=[material('M_Forest_Bark',(.12,.105,.075)),material('M_Forest_LeafDeep',(.038,.12,.036)),material('M_Forest_LeafMid',(.075,.20,.048)),material('M_Forest_LeafSun',(.16,.29,.075)),material('M_Forest_PineNeedles',(.025,.095,.055))]
class Builder:
 def __init__(self):self.v=[];self.f=[];self.mi=[]
 def face(self,vertices,slot):
  n=len(self.v);self.v.extend(vertices);self.f.append(tuple(range(n,n+len(vertices))));self.mi.append(slot)
 def branch(self,a,b,r1,r2):
  a,b=Vector(a),Vector(b);d=(b-a).normalized();u=d.cross(Vector((0,1,0))).normalized();w=d.cross(u).normalized();n=7
  for i in range(n):
   t=i*math.tau/n;q=(i+1)*math.tau/n
   self.face([a+(u*math.cos(t)+w*math.sin(t))*r1,a+(u*math.cos(q)+w*math.sin(q))*r1,b+(u*math.cos(q)+w*math.sin(q))*r2,b+(u*math.cos(t)+w*math.sin(t))*r2],0)
 def leaf(self,at,direction,length,width,slot):
  at=Vector(at);d=Vector(direction).normalized();u=d.cross(Vector((0,0,1)))
  if u.length<.01:u=Vector((1,0,0))
  u.normalize();mid=at+d*length*.47;tip=at+d*length+Vector((0,0,-length*.18));ridge=mid+Vector((0,0,width*.15));left=mid+u*width;right=mid-u*width
  # Folded double surface geometry, opaque from both sides without alpha cards.
  for pts in [[at,left,ridge],[left,tip,ridge],[tip,right,ridge],[right,at,ridge]]:
   self.face(pts,slot);self.face(list(reversed([p-Vector((0,0,.002)) for p in pts])),slot)
 def export(self,name):
  data=bpy.data.meshes.new(name);data.from_pydata(self.v,[],self.f);data.update();o=bpy.data.objects.new(name,data);scene.collection.objects.link(o)
  for m in mats:data.materials.append(m)
  for p,i in zip(data.polygons,self.mi):p.material_index=i
  minimum=min(v.co.z for v in data.vertices)
  for v in data.vertices:v.co.z-=minimum
  bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
  bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.remove_doubles(threshold=.0001);bpy.ops.uv.smart_project(island_margin=.015);bpy.ops.object.mode_set(mode='OBJECT')
  modifier=o.modifiers.new('Triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=modifier.name)
  bpy.ops.export_scene.fbx(filepath=str(OUT/(name+'.fbx')),use_selection=True,object_types={'MESH'},apply_unit_scale=True,global_scale=1,axis_forward='-Z',axis_up='Y',bake_anim=False,add_leaf_bones=False)
  return o
# Broadleaf: bent trunk, ten irregular scaffolds, each with branched twigs and distinct leaf fans.
b=Builder();trunk=[Vector((0,0,0)),Vector((.10,-.05,1.6)),Vector((-.10,.10,3.0)),Vector((.15,.03,4.4)),Vector((.0,.10,5.8))]
for i in range(4):b.branch(trunk[i],trunk[i+1],.22-i*.042,.18-i*.04)
for i in range(12):
 angle=i*2.399+ rng.uniform(-.2,.2);z=2.1+(i/11)*3.3;reach=2.15-.65*(i/11);start=Vector((.05,.03,z));end=start+Vector((math.cos(angle)*reach,math.sin(angle)*reach,.65+rng.random()*.4));b.branch(start,end,.075,.023)
 for j in range(4):
  base=start.lerp(end,.48+j*.16);a=angle+(-1 if j%2 else 1)*.65;tip=base+Vector((math.cos(a)*.65,math.sin(a)*.65,.35));b.branch(base,tip,.025,.006)
  for k in range(11):
   t=.20+k*.072;at=base.lerp(tip,t);da=a+(-1 if k%2 else 1)*rng.uniform(.65,1.45)
   b.leaf(at,(math.cos(da),math.sin(da),rng.uniform(-.1,.35)),rng.uniform(.50,.72),rng.uniform(.14,.21),rng.choice([1,2,2,3]))
  for fan in range(7):
   da=a+fan*math.tau/7
   b.leaf(tip,(math.cos(da),math.sin(da),rng.uniform(-.1,.5)),rng.uniform(.50,.70),rng.uniform(.13,.20),rng.choice([1,2,2,3]))
broad=b.export('SM_BroadleafTree')
# Pine: radial whorls with curved boughs and needle fans; no cone stacks/spheres.
b=Builder();b.branch((0,0,0),(.07,.02,6.8),.19,.025)
for layer in range(8):
 z=1.6+layer*.66;reach=2.05*(1-layer/9)
 for k in range(7):
  a=k*math.tau/7+layer*.83;start=Vector((0,0,z));mid=Vector((math.cos(a)*reach*.55,math.sin(a)*reach*.55,z-.17));end=Vector((math.cos(a)*reach,math.sin(a)*reach,z+.12));b.branch(start,mid,.04,.02);b.branch(mid,end,.02,.004)
  for j in range(6):
   at=mid.lerp(end,j/5)
   for sign in [-1,1]:
    da=a+sign*.85
    b.leaf(at,(math.cos(da),math.sin(da),.28),.46*(1-layer*.045),.11,4)
pine=b.export('SM_PineTree')
# Bush: multiple stems, divided twigs, narrow broad leaves, irregular open silhouette.
b=Builder()
for i in range(11):
 a=i*2.399;start=Vector((0,0,0));end=Vector((math.cos(a)*rng.uniform(.4,.8),math.sin(a)*rng.uniform(.4,.8),rng.uniform(.65,1.3)));b.branch(start,end,.025,.007)
 for j in range(9):
  at=start.lerp(end,.30+j*.075);da=a+(-1 if j%2 else 1)*1.0;tip=at+Vector((math.cos(da)*.2,math.sin(da)*.2,.12));b.branch(at,tip,.009,.003)
  for k in [-1,0,1]:b.leaf(tip,(math.cos(da+k*.7),math.sin(da+k*.7),.2),rng.uniform(.18,.27),.055,rng.choice([1,2,3]))
bush=b.export('SM_ForestBush')
assets=[broad,pine,bush];records=[]
for o in assets:
 records.append({'name':o.name,'file':o.name+'.fbx','triangles':len(o.data.polygons),'vertices':len(o.data.vertices),'dimensions_m':[round(float(x),4) for x in o.dimensions],'material_slots':[m.name for m in o.data.materials],'uv_layers':[u.name for u in o.data.uv_layers],'pivot':'base Z0','sha256':hashlib.sha256((OUT/(o.name+'.fbx')).read_bytes()).hexdigest()})
(OUT/'forest-generation-report.json').write_text(json.dumps({'seed':71130,'generator':'scripts/art/create-unity-forest-assets.py','blender':bpy.app.version_string,'source':'original procedural geometry; no scans/downloads/textures','assets':records},indent=2)+'\n')
broad.location=(-3,0,0);pine.location=(2.2,.7,0);bush.location=(0,-1.5,0)
ground=material('PreviewGround',(.11,.13,.10));bpy.ops.mesh.primitive_plane_add(size=100);bpy.context.object.data.materials.append(ground)
scene.world.color=(.2,.2,.2)
for loc,energy,size in [((1,-5,10),2200,8),((-6,3,8),1800,6)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=energy;o.data.size=size;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(10,-17,10));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,3.3))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=14.2;scene.camera=cam
bpy.ops.object.text_add(location=(-5,-3,.02));o=bpy.context.object;o.data.body='ORIGINAL FOREST GEOMETRY\nBLENDER PREVIEW - NOT UNITY';o.data.size=.25;o.data.materials.append(material('PreviewLabel',(.8,.8,.7)))
scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=24;scene.cycles.use_denoising=False
scene.render.resolution_x=1200;scene.render.resolution_y=850;scene.render.resolution_percentage=100;scene.render.filepath=str(ROOT/'docs/art/forest-preview.png')
BLEND_OUT=ROOT/'art-source/unity/ForestSource';BLEND_OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT/'TV_OriginalForest.blend'));bpy.ops.render.render(write_still=True)
print('FOREST_ASSETS_PASS',json.dumps(records))
