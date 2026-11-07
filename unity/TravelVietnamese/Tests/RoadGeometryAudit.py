"""Numerical audit of documented source route equations; NOT Unity mesh/runtime test.
Source parameters/formulas are manually transcribed and must be reviewed on changes.
"""
import math

def point(s):
    s=max(0,min(750,s))
    return (26*math.sin(s/85)+10*math.sin(s/37),4+s*.065+3*math.sin(s/100),s)
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def vertex(s,lane,cliff=False,valley=False):
    forward=sub(point(min(s+.2,750)),point(max(s-.2,0)))
    right=(forward[2],0,-forward[0]);length=math.sqrt(sum(x*x for x in right));right=tuple(x/length for x in right)
    p=tuple(a+lane*b for a,b in zip(point(s),right))
    height=max(0,-lane-4.25)*(.72+math.sin(s*.07)*.08) if cliff else -max(0,lane-4.25)*.55 if valley else 0
    return (p[0],p[1]+height,p[2])
strips=[('road',-3.5,3.5,False,False,False),('left shoulder',-4.25,-3.5,False,False,False),('right shoulder',3.5,4.25,False,False,True),('cliff',-65,-4.25,True,False,False),('valley',4.25,90,False,True,False)]
for name,left,right,cliff,valley,widened in strips:
    vertices=[]
    for i in range(301):
        s=i*2.5;edge=13 if any(abs(s-stop)<21 for stop in (230,550)) else 4.25
        vertices.extend((vertex(s,left,cliff,valley),vertex(s,edge if widened else right,cliff,valley)))
    normals=[]
    for i in range(300):
        a=2*i
        for x,y,z in ((a,a+2,a+1),(a+1,a+2,a+3)):
            normals.append(cross(sub(vertices[y],vertices[x]),sub(vertices[z],vertices[x]))[1])
    assert all(math.isfinite(y) and y>0 for y in normals),(name,min(normals))
    print(f'NUMERICAL: {name}: 600 triangles, min signed normal Y={min(normals):.6f}, none flipped/degenerate in XZ')
print('SOURCE-EQUATION AUDIT ONLY: 3000 sampled triangles, no local XZ winding flip; not proof against global intersections, rendering/camera clipping or Unity collider bugs.')

# New scenic terrain: derive strip bounds from current source, independently audit XZ.
from pathlib import Path
import re
landscape=(Path(__file__).resolve().parents[1]/'Assets/TravelVietnamese/Runtime/PassLandscape.cs').read_text()
for left,right in re.findall(r'TerrainChunk\(chunk,(-?[\d.]+)f?,(-?[\d.]+)f?,',landscape):
    left,right=float(left),float(right);signed=[]
    for chunk in range(15):
        for z in range(20):
            station=chunk*50+z*2.5
            for x in range(20):
                lane=left+(right-left)*x/20;next_lane=left+(right-left)*(x+1)/20
                a,b=vertex(station,lane),vertex(station+2.5,lane)
                c,d=vertex(station,next_lane),vertex(station+2.5,next_lane)
                signed.extend((cross(sub(b,a),sub(c,a))[1],cross(sub(b,c),sub(d,c))[1]))
    flipped=sum(v<=0 for v in signed)
    print(f'SCENIC XZ AUDIT: lanes {left}..{right}; {len(signed)} triangles, nonpositive={flipped}, minY={min(signed):.6f}')
    assert flipped==0,'Decorative scenic grid folds in XZ; height noise cannot remove planar self fold'
