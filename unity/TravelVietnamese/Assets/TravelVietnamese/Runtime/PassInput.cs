using UnityEngine;
namespace TravelVietnamese.UnityPrototype
{
    public sealed class PassInput : MonoBehaviour
    {
        public Vector2 Move, Look;
        public float Gas, Brake;
        public bool MountPressed, InspectPressed, ResetPressed;
        bool mouseReady;
        int stick=-1, orbit=-1; Vector2 stickOrigin,lastMouse;
        public bool Blocked;
        public void Clear(){Move=Look=Vector2.zero;Gas=Brake=0;MountPressed=InspectPressed=ResetPressed=false;stick=orbit=-1;mouseReady=false;}
        void OnApplicationFocus(bool focused){if(!focused)Clear();}
        void OnApplicationPause(bool paused){if(paused)Clear();}
        public void Poll()
        {
            Move=Look=Vector2.zero;Gas=Brake=0;
            MountPressed=InspectPressed=ResetPressed=false;
            if(Blocked || !Application.isFocused){Clear();return;}
            Move=new Vector2((Input.GetKey(KeyCode.D)?1:0)-(Input.GetKey(KeyCode.A)?1:0),(Input.GetKey(KeyCode.W)?1:0)-(Input.GetKey(KeyCode.S)?1:0));
            Gas=Input.GetKey(KeyCode.W)?1:0;Brake=Input.GetKey(KeyCode.S)?1:0;
            MountPressed=Input.GetKeyDown(KeyCode.F);InspectPressed=Input.GetKeyDown(KeyCode.E);ResetPressed=Input.GetKeyDown(KeyCode.R);
            if(mouseReady && Input.GetMouseButton(1))Look=(Vector2)Input.mousePosition-lastMouse;
            lastMouse=Input.mousePosition;mouseReady=true;
            bool stickSeen=false,orbitSeen=false;
            foreach(Touch t in Input.touches)
            {
                bool end=t.phase==TouchPhase.Ended || t.phase==TouchPhase.Canceled;
                if(end){if(t.fingerId==stick)stick=-1;if(t.fingerId==orbit)orbit=-1;continue;}
                Vector2 p=new Vector2(t.position.x/Screen.width,t.position.y/Screen.height);
                if(t.phase==TouchPhase.Began)
                {
                    if(p.x<0.36f && p.y<0.55f && stick<0){stick=t.fingerId;stickOrigin=t.position;}
                    else if(p.x>0.45f && p.y>0.34f && p.y<0.78f && orbit<0)orbit=t.fingerId;
                }
                if(t.fingerId==stick){stickSeen=true;Move=Vector2.ClampMagnitude((t.position-stickOrigin)/(Screen.height*0.12f),1); }
                else if(t.fingerId==orbit){orbitSeen=true;Look+=t.deltaPosition;}
                if(p.y>0.14f && p.y<0.30f && p.x>0.86f)Gas=1;
                else if(p.y>0.14f && p.y<0.30f && p.x>0.70f)Brake=1;
            }
            if(!stickSeen)stick=-1;if(!orbitSeen)orbit=-1;
            if(Brake>0)Gas=0;
        }
    }
}
