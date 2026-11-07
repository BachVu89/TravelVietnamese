using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    public sealed class PassRoad : MonoBehaviour
    {
        public void Build(Material road,Material shoulder,Material rock,Material foliage)
        {
            Strip("Road",-3.5f,3.5f,road,true,false,false);
            Strip("Left shoulder",-4.25f,-3.5f,shoulder,true,false,false);
            Strip("Right shoulder and stopping bays",3.5f,4.25f,shoulder,true,false,false,true);
            Strip("Rock slope",-65,-4.25f,rock,false,true,false);
            Strip("Valley slope",4.25f,90,foliage,false,false,true);
            for(int s=0;s<750;s+=5)
            {
                foreach(float side in new float[]{-1,1})
                {
                    float edge=side<0?-4.2f:PassRoute.Edge(s);
                    Vector3 a=PassRoute.At(s,edge), b=PassRoute.At(Mathf.Min(s+5,750),edge);
                    Box("Guardrail",(a+b)*0.5f+Vector3.up*0.8f,new Vector3(0.15f,0.35f,Vector3.Distance(a,b)+0.1f),Quaternion.LookRotation(b-a),shoulder,true);
                }
            }
            for(int s=3;s<747;s+=7)
                Box("Center marking",PassRoute.At(s,0)+Vector3.up*0.025f,new Vector3(0.12f,0.02f,3.5f),Quaternion.LookRotation(PassRoute.Forward(s)),shoulder,false);
            foreach(float s in new float[]{0,750}) Box("Route end barrier",PassRoute.At(s)+Vector3.up,new Vector3(8.5f,2,0.4f),Quaternion.LookRotation(PassRoute.Forward(s)),shoulder,true);
        }
        void Strip(string title,float left,float right,Material material,bool collision,bool cliff,bool valley,bool widened=false)
        {
            const int segments=300;
            Vector3[] vertices=new Vector3[(segments+1)*2]; Vector2[] uv=new Vector2[vertices.Length]; int[] triangles=new int[segments*6];
            for(int i=0;i<=segments;i++)
            {
                float s=i*2.5f;
                for(int e=0;e<2;e++)
                {
                    float lane=e==0?left:(widened?PassRoute.Edge(s):right); Vector3 p=PassRoute.At(s,lane);
                    if(cliff)p.y+=Mathf.Max(0,-lane-4.25f)*(0.72f+Mathf.Sin(s*0.07f)*0.08f);
                    if(valley)p.y-=Mathf.Max(0,lane-4.25f)*0.55f;
                    vertices[i*2+e]=p; uv[i*2+e]=new Vector2(s/5,lane/5);
                }
                if(i<segments){int a=i*2,j=i*6;triangles[j]=a;triangles[j+1]=a+2;triangles[j+2]=a+1;triangles[j+3]=a+1;triangles[j+4]=a+2;triangles[j+5]=a+3;}
            }
            GameObject go=new GameObject(title);go.transform.SetParent(transform,false);
            Mesh mesh=new Mesh();mesh.name=title;mesh.vertices=vertices;mesh.triangles=triangles;mesh.uv=uv;mesh.RecalculateNormals();mesh.RecalculateBounds();
            go.AddComponent<MeshFilter>().sharedMesh=mesh;go.AddComponent<MeshRenderer>().sharedMaterial=material;
            if(collision)go.AddComponent<MeshCollider>().sharedMesh=mesh;
        }
        public GameObject Box(string title,Vector3 position,Vector3 scale,Quaternion rotation,Material material,bool collision)
        {
            GameObject go=GameObject.CreatePrimitive(PrimitiveType.Cube);go.name=title;go.transform.SetParent(transform,false);go.transform.localPosition=position;go.transform.localRotation=rotation;go.transform.localScale=scale;
            go.GetComponent<Renderer>().sharedMaterial=material;if(!collision)Object.Destroy(go.GetComponent<Collider>());return go;
        }
    }
}
