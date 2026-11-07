#!/usr/bin/env python3
"""Original periodic procedural PBR prototype textures; no downloaded/photo input."""
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'unity/TravelVietnamese/Assets/TravelVietnamese/Art/SurfaceMaps'
N=512
OUT.mkdir(parents=True,exist_ok=True)
rng=np.random.default_rng(7112026)
def noise(grid):
    g=rng.random((grid,grid));v=np.arange(N)*grid/N;i=v.astype(int);f=v-i;f=f*f*(3-2*f)
    return (g[i[:,None],i[None,:]]*(1-f[:,None])*(1-f[None,:])+
            g[(i[:,None]+1)%grid,i[None,:]]*f[:,None]*(1-f[None,:])+
            g[i[:,None],(i[None,:]+1)%grid]*(1-f[:,None])*f[None,:]+
            g[(i[:,None]+1)%grid,(i[None,:]+1)%grid]*f[:,None]*f[None,:])
def rgb(path,data):
    Image.fromarray(np.uint8(np.clip(data,0,1)*255)).save(path)
def output(name,color,height,smoothness):
    rgb(OUT/(name+'_BaseColor.png'),color)
    dx=(np.roll(height,-1,axis=1)-np.roll(height,1,axis=1))*9
    dy=(np.roll(height,-1,axis=0)-np.roll(height,1,axis=0))*9
    normal=np.stack((-dx,-dy,np.ones_like(height)),axis=-1)
    normal/=np.linalg.norm(normal,axis=-1,keepdims=True)
    rgb(OUT/(name+'_Normal.png'),normal*.5+.5)
    # R metallic=0, G occlusion=1, B detail neutral=.5, A smoothness.
    mask=np.stack((np.zeros_like(height),np.ones_like(height),np.full_like(height,.5),smoothness),axis=-1)
    rgb(OUT/(name+'_Mask.png'),mask)
broad=noise(4);grain=noise(96);fine=rng.random((N,N));wet=np.clip((noise(8)-.52)*5,0,1)
cracks=np.zeros((N,N),dtype=np.float64)
y=np.arange(N)
for k in range(5):
    center=(k*N/5+14*np.sin(y*2*np.pi/N*(k%3+1)+k)+5*np.sin(y*2*np.pi/N*7+k)).astype(int)%N
    cracks[y,center]=1
    cracks[y,(center+1)%N]=.45
height=.045*grain+.018*fine-.055*cracks
value=(.14+.09*grain+.035*fine-.045*cracks)*(1-.28*wet)
road=np.stack((value*.92,value*.98,value),axis=-1)
output('Road',road,height,.28+.48*wet-.07*grain)
coarse=noise(10);detail=noise(72);moss=np.clip((noise(6)-.55)*5,0,1)
strata=(np.sin(np.arange(N)[:,None]*2*np.pi/N*16+noise(5)*5)*.5+.5)
height=.24*coarse+.055*detail+.035*strata
base=.25+.13*coarse+.06*detail+.025*strata
rock=np.stack((base*.91-moss*.05,base*.94+moss*.018,base*.84-moss*.055),axis=-1)
output('Rock',rock,height,.12+.16*noise(12))
soil=.16+.13*noise(24)+.055*noise(110)
output('Soil',np.stack((soil,soil*.84,soil*.61),axis=-1),.08*noise(64),.10+.12*noise(8))
records=[]
for p in sorted(OUT.glob('*.png')):
 records.append({'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(OUT/'provenance.json').write_text(json.dumps({'source':'original procedural numpy/Pillow; not scans','seed':7112026,'resolution':N,'generator':'scripts/art/create-unity-surface-maps.py','maps':records},indent=2)+'\n')
print('Generated',len(records),'original PBR maps in',OUT)
