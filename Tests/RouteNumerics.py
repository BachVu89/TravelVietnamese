"""Independent source-equation geometry audit, not Unity collision or rendering.
Equations manually transcribed from current TrailPath; review if that source changes.
"""
import math

def point(s,lane):
    tangent_x=24/170*math.cos(s/170)+10/73*math.cos(s/73)
    norm=math.sqrt(1+tangent_x*tangent_x)
    return (24*math.sin(s/170)+10*math.sin(s/73)+lane/norm,3+s*.014+2.4*math.sin(s/220),s-lane*tangent_x/norm)
def edge(s):
    weights=[]
    for bay in (260,640,1100):
        t=max(0,min(1,(abs(s-bay)-12)/6));weights.append(1-t*t*(3-2*t))
    return 2.8+(7.5-2.8)*max(weights)
def subtract(a,b):return tuple(x-y for x,y in zip(a,b))
def cross_y(a,b):return a[2]*b[0]-a[0]*b[2]
areas=[]
for s in range(0,1600,4):
    a,b=point(s,-2.8),point(s,edge(s));c,d=point(s+4,-2.8),point(s+4,edge(s+4))
    areas.extend((cross_y(subtract(c,a),subtract(b,a)),cross_y(subtract(c,b),subtract(d,b))))
assert all(math.isfinite(v) and v>0 for v in areas),'road folds or degenerates'
for stop in (260,640,1100):
    for offset in (-12,0,12):assert edge(stop+offset)>=6.5+.3,'domain bay + walker radius must fit road'
windows=[]
for station in range(1601):
    chunk=min(station//96,16);start=max(0,chunk-1);end=min(16,chunk+3)
    visible=list(range(start,end+1));assert 1<=len(visible)<=5
    assert chunk in visible and all(0<=i<=16 for i in visible)
    windows.append(len(visible))
print(f'NUMERICAL PASS: {len(areas)} road triangles finite/upward; domain bay footprint+0.3m clearance covered; 1601 sampled chunk windows max={max(windows)}.')
print('Manual equations/bounds model only: not actual TrailPath/SegmentHost engine execution or collider/graphics acceptance.')
