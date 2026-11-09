using UnityEngine;
using UnityEngine.Rendering;

namespace VietTrail.World
{
    /// <summary>Bounded, deterministic roadside tufts. No grass GameObjects or colliders.</summary>
    public sealed class GrassPatch : MonoBehaviour
    {
        Mesh mesh;
        Material material;
        Matrix4x4[] instances;
        public void Initialize(float start, float end, Material sharedGrass)
        {
            material = sharedGrass;
            // Two crossed, double-sided tapered blades; roots stay fixed in the wind shader.
            mesh = new Mesh { name = "Painterly grass tuft" };
            mesh.vertices = new[] {new Vector3(-.22f,0,0),new Vector3(.22f,0,0),new Vector3(.06f,.65f,0),
                new Vector3(0,0,-.22f),new Vector3(0,0,.22f),new Vector3(0,.55f,.06f)};
            mesh.triangles = new[] {0,2,1,1,2,0,3,4,5,5,4,3};
            Vector2 green = SegmentPainter.PaletteUV(4);
            mesh.uv = new[] {green,green,green,green,green,green};
            mesh.colors = new[] {Color.white,Color.white,Color.white,Color.white,Color.white,Color.white};
            // Shared reverse-winding triangles would cancel averaged normals.
            mesh.normals = new[] {Vector3.up,Vector3.up,Vector3.up,Vector3.up,Vector3.up,Vector3.up};
            mesh.RecalculateBounds();
            // Include maximum shader displacement in CPU-side culling bounds.
            mesh.bounds = new Bounds(new Vector3(0,.33f,0),new Vector3(1.1f,1,1.1f));
            int rows = Mathf.CeilToInt((end-start)/1.5f);
            instances = new Matrix4x4[rows*4];
            for(int row=0;row<rows;row++) for(int side=0;side<2;side++) for(int strip=0;strip<2;strip++)
            {
                float s = Mathf.Min(end-.01f,start+(row+.25f+strip*.17f)*1.5f);
                float outward = .55f+strip*.65f;
                float lane = side==0 ? -2.8f-outward : TrailPath.RightEdge(s)+outward;
                Vector3 p = SegmentPainter.RoadsideGrassPoint(s,lane);
                float phase = Mathf.Repeat(s*12.9898f+side*78.233f+strip*3.1f,1);
                instances[row*4+side*2+strip] = Matrix4x4.TRS(p,Quaternion.Euler(0,phase*360,0),Vector3.one*(.7f+phase*.5f));
            }
        }
        void LateUpdate()
        {
            if(material==null||mesh==null||!SystemInfo.supportsInstancing) return;
            // Each 96m chunk has at most 256 instances, below the API's 1023 limit.
            Graphics.DrawMeshInstanced(mesh,0,material,instances,instances.Length,null,
                ShadowCastingMode.Off,true,gameObject.layer,null,LightProbeUsage.Off);
        }
        void OnDestroy(){if(mesh!=null)Destroy(mesh);}
    }
}
