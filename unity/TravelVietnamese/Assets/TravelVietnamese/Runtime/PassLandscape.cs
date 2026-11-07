using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
namespace TravelVietnamese.UnityPrototype
{
    /// <summary>Decorative terrain and shared-mesh forest. Never adds gameplay colliders.</summary>
    public sealed class PassLandscape : MonoBehaviour
    {
        sealed class ForestBatch
        {
            public Mesh Mesh;public Material Material;public int Submesh;
            public readonly List<Matrix4x4> Instances=new List<Matrix4x4>();
            public Matrix4x4[] Matrices;public Vector3 Center;
        }
        readonly Dictionary<string,ForestBatch> batches=new Dictionary<string,ForestBatch>();
        public int ForestInstanceCount {get;private set;}
        public int TerrainVertexCount {get;private set;}
        public static Vector3 SurfacePoint(float s,float lane)
        {
            Vector3 p=PassRoute.At(s,lane);float edge=Mathf.Max(0,Mathf.Abs(lane)-4.25f);
            if(lane<0)p.y+=edge*(0.72f+Mathf.Sin(s*0.07f)*0.08f);
            else p.y-=edge*0.55f;
            float fade=1-Mathf.Exp(-edge/12);
            float ridge=Mathf.Sin(s*0.033f+edge*0.11f)*Mathf.Cos(edge*0.047f-s*0.018f);
            float broken=Mathf.PerlinNoise(s*0.021f+4,edge*0.043f+9)-0.5f;
            p.y+=fade*(ridge*7+broken*9+Mathf.Sin(s*0.008f+edge*0.022f)*edge*0.10f);
            // The existing stopping-bay collider is flat across lanes 3.5..13.
            // Extend a below-floor safety apron past its edges so coarse decorative
            // triangles cannot emerge through that unchanged playable pad.
            if(lane>4.25f && lane<24)
                foreach(float stop in TravelVietnamese.Domain.PassRules.StopDistances)
                    if(Mathf.Abs(s-stop)<30)p.y=Mathf.Min(p.y,PassRoute.Point(s).y-Mathf.Min(0.3f,edge*0.2f));
            return p;
        }
        public void Build(Material rock,Material soil,GameObject broadleaf,GameObject pine,GameObject bush,GameObject rockPrefab)
        {
            for(int chunk=0;chunk<15;chunk++)
            {
                TerrainChunk(chunk,-90,-4.25f,rock);
                TerrainChunk(chunk,4.25f,90,soil);
            }
            Backdrop(rock,soil);
            var rng=new System.Random(41004);
            for(int i=0;i<1020;i++)
            {
                float s=(float)rng.NextDouble()*750;float side=i%3==0?-1:1;
                float lane=side*(side<0?7+(float)rng.NextDouble()*73:18+(float)rng.NextDouble()*65);
                GameObject prefab=i%5==0?pine:broadleaf;if(prefab==null)prefab= pine;
                float scale=0.85f+(float)rng.NextDouble()*0.9f;
                AddPrefab(prefab,SurfacePoint(s,lane),Quaternion.Euler(0,(float)rng.NextDouble()*360,0),scale,(int)(s/50));
            }
            for(int i=0;i<380;i++)
            {
                float s=(float)rng.NextDouble()*750;float side=i%2==0?-1:1;
                float lane=side*(side<0?5.3f+(float)rng.NextDouble()*22:17+(float)rng.NextDouble()*35);
                AddPrefab(i%6==0?rockPrefab:bush,SurfacePoint(s,lane),Quaternion.Euler(0,(float)rng.NextDouble()*360,0),0.7f+(float)rng.NextDouble()*0.9f,(int)(s/50));
            }
            foreach(ForestBatch batch in batches.Values)
            {
                batch.Matrices=batch.Instances.ToArray();
                foreach(Matrix4x4 matrix in batch.Matrices)batch.Center+=(Vector3)matrix.GetColumn(3);
                batch.Center/=Mathf.Max(1,batch.Matrices.Length);
                batch.Material.enableInstancing=true;
            }
        }
        void TerrainChunk(int chunk,float left,float right,Material material)
        {
            const int along=20,across=20;Vector3[] vertices=new Vector3[(along+1)*(across+1)];Vector2[] uv=new Vector2[vertices.Length];int[] indices=new int[along*across*6];
            for(int z=0;z<=along;z++)for(int x=0;x<=across;x++)
            {
                float s=chunk*50+z*2.5f;float lane=Mathf.Lerp(left,right,(float)x/across);int i=z*(across+1)+x;
                vertices[i]=SurfacePoint(s,lane);uv[i]=new Vector2(s/12,lane/12);
                if(z<along && x<across){int j=(z*across+x)*6,a=i,b=i+across+1;indices[j]=a;indices[j+1]=b;indices[j+2]=a+1;indices[j+3]=a+1;indices[j+4]=b;indices[j+5]=b+1;}
            }
            MakeMesh("Ridged terrain chunk "+chunk,vertices,indices,uv,material);
        }
        void Backdrop(Material rock,Material soil)
        {
            for(int layer=0;layer<3;layer++)
            {
                const int rows=7,columns=40;Vector3[] v=new Vector3[(rows+1)*(columns+1)];Vector2[] uv=new Vector2[v.Length];int[] indices=new int[rows*columns*6];
                for(int z=0;z<=columns;z++)for(int x=0;x<=rows;x++)
                {
                    float station=-250+z*32;float lateral=140+layer*100+x*26;
                    float peak=65+layer*38+Mathf.Sin(station*0.013f+layer*2)*34+Mathf.PerlinNoise(station*0.008f+8,layer*3+2)*65;
                    float crest=Mathf.Sin((float)x/rows*Mathf.PI);
                    int i=z*(rows+1)+x;v[i]=new Vector3(lateral, -55+peak*crest+Mathf.Sin(x*1.4f+z)*8,station);uv[i]=new Vector2(lateral/30,station/30);
                    if(z<columns && x<rows){int j=(z*rows+x)*6,a=i,b=i+rows+1;indices[j]=a;indices[j+1]=b;indices[j+2]=a+1;indices[j+3]=a+1;indices[j+4]=b;indices[j+5]=b+1;}
                }
                MakeMesh("Distant mountain ridge "+layer,v,indices,uv,layer==0?soil:rock);
            }
        }
        void MakeMesh(string title,Vector3[] vertices,int[] triangles,Vector2[] uv,Material material)
        {
            var mesh=new Mesh();mesh.name=title;mesh.vertices=vertices;mesh.triangles=triangles;mesh.uv=uv;mesh.RecalculateNormals();mesh.RecalculateTangents();mesh.RecalculateBounds();TerrainVertexCount+=vertices.Length;
            GameObject go=new GameObject(title);go.transform.SetParent(transform,false);go.AddComponent<MeshFilter>().sharedMesh=mesh;go.AddComponent<MeshRenderer>().sharedMaterial=material;
        }
        void AddPrefab(GameObject prefab,Vector3 position,Quaternion rotation,float scale,int chunk)
        {
            if(prefab==null)return;ForestInstanceCount++;
            Matrix4x4 placement=Matrix4x4.TRS(position,rotation,Vector3.one*scale);
            foreach(MeshFilter filter in prefab.GetComponentsInChildren<MeshFilter>(true))
            {
                MeshRenderer renderer=filter.GetComponent<MeshRenderer>();Mesh mesh=filter.sharedMesh;if(renderer==null || mesh==null)continue;
                Material[] materials=renderer.sharedMaterials;
                for(int sub=0;sub<mesh.subMeshCount && sub<materials.Length;sub++)
                {
                    Material material=materials[sub];if(material==null)continue;
                    string key=chunk+":"+mesh.GetInstanceID()+":"+sub+":"+material.GetInstanceID();ForestBatch batch;
                    if(!batches.TryGetValue(key,out batch)){batch=new ForestBatch{Mesh=mesh,Material=material,Submesh=sub};batches.Add(key,batch);}
                    batch.Instances.Add(placement*prefab.transform.worldToLocalMatrix*filter.transform.localToWorldMatrix);
                }
            }
        }
        void LateUpdate()
        {
            Camera camera=Camera.main;if(camera==null)return;
            foreach(ForestBatch batch in batches.Values)
            {
                if(batch.Matrices==null || Vector3.Distance(camera.transform.position,batch.Center)>330)continue;
                if(SystemInfo.supportsInstancing && batch.Matrices.Length<=1023)
                    Graphics.DrawMeshInstanced(batch.Mesh,batch.Submesh,batch.Material,batch.Matrices,batch.Matrices.Length,null,ShadowCastingMode.On,true,gameObject.layer);
                else foreach(Matrix4x4 matrix in batch.Matrices)Graphics.DrawMesh(batch.Mesh,matrix,batch.Material,gameObject.layer,null,batch.Submesh);
            }
        }
    }
}
