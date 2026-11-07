using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    /// <summary>Third-person camera collision only; never changes player movement or progress.</summary>
    public sealed class PassCameraRig : MonoBehaviour
    {
        readonly RaycastHit[] hits = new RaycastHit[64];
        float currentDistance;
        bool snapNext = true;
        public float LastAllowedDistance {get;private set;}
        public float LastCollisionRadius {get;private set;}
        public int LastWorldHitCount {get;private set;}
        public void RequestSnap(){snapNext=true;}
        void OnApplicationFocus(bool focused){snapNext=true;}
        void OnApplicationPause(bool paused){snapNext=true;}
        static bool Owned(Collider collider,Transform owner)
        {return owner!=null && (collider.transform==owner || collider.transform.IsChildOf(owner));}
        static bool Meaningful(RaycastHit hit,Transform bike,Transform walker)
        {
            Collider collider=hit.collider;
            return collider!=null && !CameraOcclusionRules.ShouldIgnore(collider.isTrigger,Owned(collider,bike)||Owned(collider,walker))
                && PassRules.Finite(hit.distance) && hit.distance>=0;
        }
        public void Apply(Camera camera,Vector3 pivot,Quaternion orbit,float desiredDistance,Transform bike,Transform walker,float deltaSeconds)
        {
            if(camera==null || !Finite(pivot))return;
            camera.nearClipPlane=PassRules.Finite(camera.nearClipPlane)?Mathf.Clamp(camera.nearClipPlane,0.03f,0.5f):0.12f;
            Vector3 backwards=-(orbit*Vector3.forward);
            if(!Finite(backwards) || backwards.sqrMagnitude<0.000001f)return;
            backwards.Normalize();
            float desired=PassRules.Finite(desiredDistance)?Mathf.Max(0.05f,desiredDistance):5;
            float radius=CameraOcclusionRules.CollisionRadius(camera.nearClipPlane,camera.fieldOfView,camera.aspect);
            LastCollisionRadius=radius;LastWorldHitCount=0;
            float nearest=float.PositiveInfinity;
            // DefaultRaycastLayers queries real world layers, not only layer 0. Ownership
            // filtering is explicit so both active and parked actors cannot retract the camera.
            int count=Physics.SphereCastNonAlloc(pivot,radius,backwards,hits,desired,Physics.DefaultRaycastLayers,QueryTriggerInteraction.Ignore);
            for(int i=0;i<count;i++)if(Meaningful(hits[i],bike,walker)){nearest=Mathf.Min(nearest,hits[i].distance);LastWorldHitCount++;}
            if(count==hits.Length)
            {
                // NonAlloc results are unsorted and may omit the nearest world hit when full.
                // Allocate only on saturation rather than trusting a truncated physics query.
                RaycastHit[] overflow=Physics.SphereCastAll(pivot,radius,backwards,desired,Physics.DefaultRaycastLayers,QueryTriggerInteraction.Ignore);
                LastWorldHitCount=0;
                foreach(RaycastHit hit in overflow)if(Meaningful(hit,bike,walker)){nearest=Mathf.Min(nearest,hit.distance);LastWorldHitCount++;}
            }
            LastAllowedDistance=CameraOcclusionRules.AllowedDistance(desired,nearest,0.08f);
            currentDistance=CameraOcclusionRules.RecoverDistance(currentDistance,LastAllowedDistance,deltaSeconds,6,snapNext);
            snapNext=false;
            // A zero-distance overlap never feeds hit.normal or a zero vector to LookRotation.
            camera.transform.position=pivot+backwards*currentDistance;
            camera.transform.rotation=Quaternion.LookRotation(-backwards,Vector3.up);
        }
        static bool Finite(Vector3 value)
        {return PassRules.Finite(value.x)&&PassRules.Finite(value.y)&&PassRules.Finite(value.z);}
    }
}
