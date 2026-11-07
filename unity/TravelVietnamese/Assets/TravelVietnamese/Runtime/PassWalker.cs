using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class PassWalker : MonoBehaviour
    {
        public Vector2 Move;public float CameraYaw;public bool Blocked;
        CharacterController body;float fall;
        void Awake(){body=GetComponent<CharacterController>();body.height=1.8f;body.radius=0.33f;body.center=Vector3.up*0.9f;body.stepOffset=0.3f;body.slopeLimit=48;}
        public void Step(float dt)
        {
            if(Blocked){Move=Vector2.zero;return;}
            Vector3 direction=Quaternion.Euler(0,CameraYaw,0)*new Vector3(Move.x,0,Move.y);
            if(direction.sqrMagnitude>1)direction.Normalize();
            if(direction.sqrMagnitude>0.01f)transform.rotation=Quaternion.Slerp(transform.rotation,Quaternion.LookRotation(direction),Mathf.Min(1,dt*12));
            fall=body.isGrounded?-2:fall-24*dt;body.Move((direction*4.5f+Vector3.up*fall)*dt);
        }
        public void Place(Vector3 position){body.enabled=false;transform.position=position;body.enabled=true;fall=0;}
        public void SetActive(bool value){body.enabled=value;gameObject.SetActive(value);}
    }
}
