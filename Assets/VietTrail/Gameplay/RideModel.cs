using System.Collections.Generic;
using UnityEngine;
namespace VietTrail.Gameplay
{
    /// <summary>Original small palette-mapped meshes; no imported character or vehicle.</summary>
    public static class RideModel
    {
        sealed class Builder
        {
            readonly List<Vector3> vertices=new List<Vector3>();readonly List<int> indices=new List<int>();readonly List<Vector2> uv=new List<Vector2>();
            public void Triangle(Vector3 a,Vector3 b,Vector3 c,int color)
            {
                int n=vertices.Count;vertices.Add(a);vertices.Add(b);vertices.Add(c);indices.Add(n);indices.Add(n+1);indices.Add(n+2);
                Vector2 sample=new Vector2((color%8+0.5f)/8,(color/8+0.5f)/8);uv.Add(sample);uv.Add(sample);uv.Add(sample);
            }
            public void Panel(Vector3 center,Vector3 size,int color)
            {
                Vector3[] ring=new Vector3[8];
                for(int i=0;i<8;i++){float a=Mathf.PI*0.25f*i;ring[i]=new Vector3(Mathf.Cos(a)*size.x*0.5f,0,Mathf.Sin(a)*size.z*0.5f);}
                for(int i=0;i<8;i++)
                {
                    int j=(i+1)%8;Vector3 a=center+ring[i]+Vector3.up*size.y*0.5f,b=center+ring[j]+Vector3.up*size.y*0.5f,c=center+ring[i]-Vector3.up*size.y*0.5f,d=center+ring[j]-Vector3.up*size.y*0.5f;
                    Triangle(center+Vector3.up*size.y*0.5f,b,a,color);Triangle(center-Vector3.up*size.y*0.5f,c,d,color);Triangle(a,b,c,color);Triangle(c,b,d,color);
                }
            }
            public void Tube(Vector3 a,Vector3 b,float radius,int color)
            {
                Vector3 axis=(b-a).normalized;Vector3 cross=Vector3.Cross(axis,Mathf.Abs(axis.y)>0.9f?Vector3.right:Vector3.up).normalized;Vector3 other=Vector3.Cross(axis,cross);
                for(int i=0;i<10;i++)
                {
                    float t=i*Mathf.PI*0.2f,u=(i+1)*Mathf.PI*0.2f;Vector3 p=(cross*Mathf.Cos(t)+other*Mathf.Sin(t))*radius,q=(cross*Mathf.Cos(u)+other*Mathf.Sin(u))*radius;
                    Triangle(a+p,a+q,b+p,color);Triangle(a+q,b+q,b+p,color);Triangle(a,a+q,a+p,color);Triangle(b,b+p,b+q,color);
                }
            }
            public GameObject Finish(string name,Transform parent,Material material)
            {
                Mesh mesh=new Mesh{name=name};mesh.SetVertices(vertices);mesh.SetTriangles(indices,0);mesh.SetUVs(0,uv);var colors=new Color[vertices.Count];for(int i=0;i<colors.Length;i++)colors[i]=new Color(1,1,1,0);mesh.colors=colors;mesh.RecalculateNormals();mesh.RecalculateBounds();
                GameObject result=new GameObject(name);result.transform.SetParent(parent,false);result.AddComponent<MeshFilter>().sharedMesh=mesh;result.AddComponent<MeshRenderer>().sharedMaterial=material;return result;
            }
        }
        public static GameObject Bike(Transform parent,Material material,int color,out Transform front,out Transform rear,out Transform bars)
        {
            int paint=color==0?10:color==1?13:15;Builder m=new Builder();
            m.Panel(new Vector3(0,0.54f,-0.05f),new Vector3(0.31f,0.25f,0.65f),paint);
            m.Panel(new Vector3(0,0.81f,-0.27f),new Vector3(0.43f,0.15f,0.75f),11);
            m.Panel(new Vector3(0,0.7f,0.32f),new Vector3(0.5f,0.65f,0.19f),9);
            m.Panel(new Vector3(0,0.46f,0.14f),new Vector3(0.46f,0.08f,0.61f),paint);
            m.Tube(new Vector3(0,0.36f,0.65f),new Vector3(0,1.04f,0.45f),0.055f,11);
            m.Tube(new Vector3(0.22f,0.33f,-0.4f),new Vector3(0.22f,0.34f,-0.76f),0.055f,11);
            m.Panel(new Vector3(0,1.02f,0.48f),new Vector3(0.26f,0.16f,0.18f),9);
            GameObject root=m.Finish("Classic step-through silhouette",parent,material);
            front=Wheel(root.transform,material,0.65f);rear=Wheel(root.transform,material,-0.65f);
            Builder handle=new Builder();handle.Tube(new Vector3(-0.32f,0,0),new Vector3(0.32f,0,0),0.035f,11);bars=handle.Finish("Handlebar",root.transform,material).transform;bars.localPosition=new Vector3(0,1.09f,0.43f);
            return root;
        }
        static Transform Wheel(Transform parent,Material material,float z)
        {
            Builder m=new Builder();m.Tube(new Vector3(-0.08f,0,0),new Vector3(0.08f,0,0),0.32f,11);m.Tube(new Vector3(-0.086f,0,0),new Vector3(0.086f,0,0),0.20f,9);
            Transform wheel=m.Finish("Wheel",parent,material).transform;wheel.localPosition=new Vector3(0,0.34f,z);return wheel;
        }
        public static GameObject Person(Transform parent,Material material,bool seated)
        {
            Builder m=new Builder();float hip=seated?0.94f:0.86f;float torso=seated?1.2f:1.19f;
            m.Panel(new Vector3(0,torso,seated?-0.14f:0),new Vector3(0.43f,0.56f,0.3f),13);
            m.Panel(new Vector3(0,torso,seated?-0.35f:-0.23f),new Vector3(0.33f,0.43f,0.22f),14);
            m.Panel(new Vector3(0,seated?1.65f:1.65f,seated?-0.06f:0),new Vector3(0.4f,0.34f,0.39f),9);
            m.Panel(new Vector3(0,1.63f,seated?0.13f:0.18f),new Vector3(0.31f,0.12f,0.08f),12);
            for(int side=-1;side<=1;side+=2)
            {
                Vector3 shoulder=new Vector3(side*0.23f,torso+0.15f,seated?-0.1f:0),elbow=new Vector3(side*0.29f,torso-0.08f,seated?0.14f:0.02f),hand=new Vector3(side*0.27f,seated?1.09f:0.78f,seated?0.43f:0.05f);
                m.Tube(shoulder,elbow,0.075f,13);m.Tube(elbow,hand,0.065f,13);
                Vector3 top=new Vector3(side*0.14f,hip,seated?-0.28f:0),knee=new Vector3(side*0.25f,seated?0.62f:0.48f,seated?0.15f:0.03f),foot=new Vector3(side*0.23f,seated?0.44f:0.12f,seated?0.10f:0.06f);
                m.Tube(top,knee,0.09f,15);m.Tube(knee,foot,0.08f,15);m.Panel(foot,new Vector3(0.18f,0.12f,0.29f),11);
            }
            return m.Finish(seated?"Helmet rider and ochre backpack":"Walking traveller",parent,material);
        }
    }
}
