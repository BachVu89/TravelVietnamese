"""Original generic touring motorcycle and clothed explorers; Blender background only."""
import bpy, math, json, hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'unity/TravelVietnamese/Assets/TravelVietnamese/Art/TravelSource';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene;scene.unit_settings.system='METRIC';scene.unit_settings.scale_length=1
mats={}
for name,color,metal,rough in [
 ('Rubber',(.025,.03,.028),0,.83),('Steel',(.32,.36,.34),.75,.3),('OlivePaint',(.10,.16,.12),.25,.38),
 ('Leather',(.08,.055,.035),0,.85),('Lamp',(.84,.72,.45),.05,.22),('TailLamp',(.48,.025,.012),.1,.3),
 ('Cloth',(.16,.21,.15),0,.91),('Boot',(.055,.043,.032),0,.86),('Helmet',(.12,.15,.13),.2,.32),
 ('Visor',(.025,.038,.04),.25,.2),('Pack',(.24,.20,.13),0,.95),('Skin',(.40,.27,.19),0,.8)]:
 m=bpy.data.materials.new('TV_'+name);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough;m.diffuse_color=(*color,1);mats[name]=m
parts=[]
def finish(obj,material):
 obj.data.materials.append(mats[material]);parts.append(obj)
 for poly in obj.data.polygons:poly.use_smooth=True
 return obj
def ell(center,scale,material):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,location=center);o=bpy.context.object;o.scale=scale;return finish(o,material)
def tube(a,b,r,material,vertices=10):
 a,b=Vector(a),Vector(b);d=b-a;bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d.length,location=(a+b)*.5);o=bpy.context.object;o.rotation_euler=d.to_track_quat('Z','Y').to_euler();return finish(o,material)
def rounded(center,scale,material,bevel=.04):
 bpy.ops.mesh.primitive_cube_add(size=1,location=center);o=bpy.context.object;o.scale=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 mod=o.modifiers.new('Rounded manufacturing edges','BEVEL');mod.width=bevel;mod.segments=2;bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name);return finish(o,material)
def torus(center,major,minor,material):
 bpy.ops.mesh.primitive_torus_add(major_segments=36,minor_segments=8,location=center,major_radius=major,minor_radius=minor,rotation=(0,math.pi/2,0));return finish(bpy.context.object,material)
def join_export(name):
 bpy.ops.object.select_all(action='DESELECT')
 for o in parts:o.select_set(True)
 bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join();o=parts[0];o.name=name
 # Apply all transforms and ground the authored pivot (standing/riding roots in metres).
 bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
 bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
 bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(island_margin=.015);bpy.ops.object.mode_set(mode='OBJECT')
 mod=o.modifiers.new('Export triangulation','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name)
 path=OUT/(name+'.fbx')
 bpy.ops.export_scene.fbx(filepath=str(path),use_selection=True,object_types={'MESH'},apply_unit_scale=True,global_scale=1,axis_forward='-Z',axis_up='Y',add_leaf_bones=False,bake_anim=False)
 record={'name':name,'file':path.name,'triangles':len(o.data.polygons),'vertices':len(o.data.vertices),'material_slots':[m.name for m in o.data.materials],
         'dimensions_m':[round(v,4) for v in o.dimensions],'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'forward':'Blender -Y; FBX -Z forward/Y up conversion; verify Unity scale/orientation'}
 parts.clear();return o,record
# Generic motorcycle. Wheel axles run X; front wheel is at negative Y.
for y in [-.78,.78]:
 torus((0,y,.34),.275,.068,'Rubber');torus((0,y,.34),.218,.014,'Steel')
 tube((-.11,y,.34),(.11,y,.34),.065,'Steel')
 for i in range(18):
  a=i*math.tau/18;tube((0,y,.34),(0,y+math.cos(a)*.215,.34+math.sin(a)*.215),.004,'Steel',6)
 # Curved metal fender follows the upper half of each wheel.
 verts=[];faces=[]
 for i in range(17):
  a=math.pi*i/16
  for x in [-.105,.105]:verts.append((x,y+math.cos(a)*.37,.34+math.sin(a)*.37))
 for i in range(16):q=i*2;faces.append((q,q+1,q+3,q+2))
 mesh=bpy.data.meshes.new('Curved fender');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('Fender',mesh);scene.collection.objects.link(o);finish(o,'OlivePaint')
for side in [-1,1]:
 x=side*.105;tube((x,-.78,.34),(x,-.59,1.02),.025,'Steel');tube((x,.78,.34),(x,.38,.88),.023,'Steel')
 tube((x,.78,.34),(x,-.1,.43),.028,'Steel');tube((x,-.1,.43),(x,-.42,.99),.033,'OlivePaint')
rounded((0,.20,.94),(.42,.80,.12),'Leather');ell((0,-.27,.81),(.22,.32,.18),'OlivePaint')
rounded((0,-.02,.48),(.32,.34,.32),'Steel',.05)
for z in [.41,.46,.51,.56]:rounded((0,-.06,z),(.39,.36,.015),'Steel',.004)
tube((.21,.1,.4),(.22,.78,.37),.045,'Steel');tube((-.24,-.1,.3),(.24,-.1,.3),.02,'Steel')
tube((-.37,-.58,1.12),(.37,-.58,1.12),.019,'Steel')
for side in [-1,1]:
 tube((side*.28,-.58,1.12),(side*.39,-.58,1.12),.025,'Rubber')
 tube((side*.27,-.59,1.12),(side*.35,-.62,1.34),.009,'Steel');ell((side*.35,-.62,1.36),(.072,.022,.043),'Visor')
ell((0,-.69,.97),(.13,.09,.12),'Steel');ell((0,-.765,.97),(.105,.012,.09),'Lamp')
rounded((0,.74,.77),(.14,.045,.09),'TailLamp',.01)
rounded((0,.92,.61),(.17,.018,.11),'Steel',.008)
# Rear luggage and straps: original generic bag, no branded parts.
rounded((0,.67,1.11),(.40,.34,.23),'Pack',.045)
for x in [-.13,.13]:rounded((x,.67,1.23),(.035,.36,.015),'Leather',.004)
bike,rb=join_export('SM_TouringMotorbike')
# Clothed proportioned visual characters, static pose (no skeletal animation claimed).
def human(seated):
 hips=Vector((0,.16,1.03 if seated else .91));shoulders=Vector((0,.08,1.48 if seated else 1.38))
 ell((hips+shoulders)*.5,(.225,.135,.31),'Cloth');ell(hips,(.19,.14,.14),'Cloth')
 for side in [-1,1]:
  hip=hips+Vector((side*.12,0,-.03));knee=Vector((side*.24,-.32,.64)) if seated else Vector((side*.12,-.015,.49))
  ankle=Vector((side*.25,-.04,.30)) if seated else Vector((side*.12,.015,.11))
  tube(hip,knee,.085,'Cloth',12);ell(knee,(.086,.09,.09),'Cloth');tube(knee,ankle,.065,'Cloth',12)
  rounded(ankle+Vector((0,-.07,-.035)),(.14,.29,.13),'Boot',.035)
  shoulder=shoulders+Vector((side*.20,0,0));elbow=Vector((side*.31,-.22,1.20)) if seated else Vector((side*.29,.02,1.08))
  hand=Vector((side*.31,-.57,1.12)) if seated else Vector((side*.28,-.02,.85))
  tube(shoulder,elbow,.07,'Cloth',12);ell(elbow,(.071,.075,.078),'Cloth');tube(elbow,hand,.052,'Cloth',12);ell(hand,(.055,.067,.052),'Leather')
 neck=shoulders+Vector((0,0,.05));tube(neck,neck+Vector((0,0,.08)),.06,'Skin')
 head=neck+Vector((0,-.015,.16));ell(head,(.145,.155,.17),'Helmet');ell(head+Vector((0,-.12,-.015)),(.125,.055,.085),'Visor')
 pack=shoulders+Vector((0,.19,-.10));rounded(pack,(.36,.23,.45),'Pack',.07)
 rounded(pack+Vector((0,.13,-.075)),(.25,.07,.18),'Leather',.025)
 for side in [-1,1]:tube(shoulders+Vector((side*.15,-.10,.04)),hips+Vector((side*.13,-.11,.06)),.018,'Pack',8)
 return join_export('SM_RiderSeated' if seated else 'SM_ExplorerStanding')
rider,rr=human(True);walker,rw=human(False)
(OUT/'provenance.json').write_text(json.dumps({'source':'Original Blender procedural geometry; no scans, downloads or branded model inputs','generator':'scripts/art/create-unity-travel-characters.py','blender_version':bpy.app.version_string,'assets':[rb,rr,rw]},indent=2)+'\n')
# Render the actual assets together for authoring review only, not a Unity screenshot.
bike.location.x=-1.5;rider.location.x=-1.5;walker.location.x=1.05
bpy.ops.mesh.primitive_plane_add(size=200);plane=bpy.context.object;plane.data.materials.append(mats['Rubber'])
world=scene.world or bpy.data.worlds.new('World');scene.world=world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.32,.38,.40,1);world.node_tree.nodes['Background'].inputs[1].default_value=.65
bpy.ops.object.light_add(type='AREA',location=(-2,-3,7));bpy.context.object.data.energy=1100;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=6
bpy.ops.object.camera_add(location=(-4.9,-6.4,3.3));cam=bpy.context.object;cam.rotation_euler=(Vector((-.4,0,1))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.lens=52;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=24;scene.cycles.use_denoising=False
scene.render.resolution_x=1100;scene.render.resolution_y=720;scene.render.resolution_percentage=100
BLEND_OUT=ROOT/'art-source/unity/TravelSource';BLEND_OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT/'TravelCharacters.blend'))
scene.render.filepath=str(ROOT/'docs/art/travel-characters-preview.png');bpy.ops.render.render(write_still=True)
print('ORIGINAL_TRAVEL_ASSETS_COMPLETE',json.dumps([rb,rr,rw]))
