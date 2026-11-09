using UnityEngine;
namespace VietTrail.Gameplay
{
    /// <summary>Camera-only obstruction solver; owns no progress or actor physics.</summary>
    public sealed class TrailViewRig : MonoBehaviour
    {
        readonly RaycastHit[] buffer=new RaycastHit[48];float distance;bool snap=true;
        public void Snap(){snap=true;}
        bool Owned(Collider collider,Transform bike,Transform walker)
        {return collider==null||collider.isTrigger||(bike!=null&&(collider.transform==bike||collider.transform.IsChildOf(bike)))||(walker!=null&&(collider.transform==walker||collider.transform.IsChildOf(walker)));}
        public void Follow(Camera camera,Vector3 pivot,Quaternion rotation,float reach,Transform bike,Transform walker,float dt)
        {
            camera.nearClipPlane=0.08f;Vector3 backwards=-(rotation*Vector3.forward);float halfHeight=camera.nearClipPlane*Mathf.Tan(camera.fieldOfView*Mathf.Deg2Rad*0.5f);
            float radius=Mathf.Max(0.25f,Mathf.Sqrt(camera.nearClipPlane*camera.nearClipPlane+halfHeight*halfHeight*(1+camera.aspect*camera.aspect))+0.07f);
            float allowed=reach;int count=Physics.SphereCastNonAlloc(pivot,radius,backwards,buffer,reach,Physics.DefaultRaycastLayers,QueryTriggerInteraction.Ignore);
            for(int i=0;i<count;i++)if(!Owned(buffer[i].collider,bike,walker))allowed=Mathf.Min(allowed,Mathf.Max(0,buffer[i].distance-0.08f));
            if(count==buffer.Length)foreach(RaycastHit hit in Physics.SphereCastAll(pivot,radius,backwards,reach,Physics.DefaultRaycastLayers,QueryTriggerInteraction.Ignore))if(!Owned(hit.collider,bike,walker))allowed=Mathf.Min(allowed,Mathf.Max(0,hit.distance-0.08f));
            distance=snap||allowed<distance?allowed:Mathf.MoveTowards(distance,allowed,Mathf.Max(0,dt)*5);snap=false;
            camera.transform.SetPositionAndRotation(pivot+backwards*distance,rotation);
        }
    }
}
