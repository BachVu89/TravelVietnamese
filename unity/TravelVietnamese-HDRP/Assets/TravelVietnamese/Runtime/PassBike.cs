using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class PassBike : MonoBehaviour
    {
        public float Speed {get;private set;}
        public bool Riding=true;
        public Vector2 Drive;
        public bool Blocked;
        CharacterController body;float fall;
        void Awake(){body=GetComponent<CharacterController>();body.height=1.8f;body.radius=0.38f;body.center=Vector3.up*0.95f;body.stepOffset=0.3f;body.slopeLimit=48;}
        public void Step(float dt)
        {
            if(Blocked || !Riding){Speed=0;Drive=Vector2.zero;return;}
            float acceleration=Drive.y>0?PassRules.Acceleration*Drive.y:(Drive.y<0?-PassRules.Brake*-Drive.y:-1.2f);
            Speed=Mathf.Clamp(Speed+acceleration*dt,0,PassRules.MaxSpeed);
            transform.Rotate(0,Drive.x*Mathf.Min(Speed/7,1)*48*dt,0);
            fall=body.isGrounded?-2:fall-24*dt;
            CollisionFlags hit=body.Move((transform.forward*Speed+Vector3.up*fall)*dt);
            if((hit&CollisionFlags.Sides)!=0)Speed=0;
        }
        public void Stop(){Speed=fall=0;Drive=Vector2.zero;}
        public void Place(float s,float lane)
        {
            body.enabled=false;transform.position=PassRoute.At(s,lane)+Vector3.up*0.15f;transform.rotation=Quaternion.LookRotation(PassRoute.Forward(s),Vector3.up);body.enabled=true;
            Speed=fall=0;Drive=Vector2.zero;
        }
    }
}
