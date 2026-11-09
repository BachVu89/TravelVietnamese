using System;
using UnityEngine;
using VietTrail.Core;
using VietTrail.World;
namespace VietTrail.Gameplay
{
    /// <summary>Original small, offline ride/walk director. Unity play and device tests remain required.</summary>
    public sealed class RiderDirector : MonoBehaviour
    {
        public event Action Changed;
        public event Action<string> Message;
        public Camera ViewCamera {get;private set;}
        public bool IsRiding {get;private set;}
        public float SpeedKmh {get{return speed*3.6f;}}
        public float Meters {get{return initialized?Station(Active.position):state.meters;}}
        public JourneyState State {get{Snapshot();return state;}}
        public bool Controllable {get{return initialized&&!paused&&!title&&!unfocused;}}
        JourneyState state=new JourneyState();SegmentHost world;Material palette;
        CharacterController bike,walker;Transform seated,front,rear,bars;GameObject bikeModel,person;
        TrailViewRig viewRig;bool externalCamera;bool initialized,paused,title,unfocused;float speed,bikeFall,walkFall,yaw,pitch=17;
        float touchSteer,touchGas,touchBrake;Vector2 touchMove,look;Vector3 lastMouse;bool mouseReady;
        Transform Active {get{return IsRiding?bike.transform:walker.transform;}}
        public void Initialize(Material paletteMaterial,SegmentHost host,JourneyState loaded)
        {
            if(initialized)return;palette=paletteMaterial;world=host;state=RideRules.Normalize(loaded);
            world.WarmStart(state.meters,palette);
            bike=Body("Step-through scooter",0.34f,1.75f);walker=Body("Traveller",0.29f,1.78f);
            bikeModel=RideModel.Bike(bike.transform,palette,state.options.bikeColor,out front,out rear,out bars);
            seated=RideModel.Person(bike.transform,palette,true).transform;person=RideModel.Person(walker.transform,palette,false);
            PositionBike(state.meters,state.lane);IsRiding=true;walker.gameObject.SetActive(false);
            GameObject cameraObject=new GameObject("VietTrail follow camera");cameraObject.transform.SetParent(transform,false);
            ViewCamera=cameraObject.AddComponent<Camera>();ViewCamera.fieldOfView=57;ViewCamera.nearClipPlane=0.08f;ViewCamera.farClipPlane=420;
            Camera previous=Camera.main;if(previous!=null&&previous!=ViewCamera)previous.enabled=false;cameraObject.tag="MainCamera";
            viewRig=cameraObject.AddComponent<TrailViewRig>();yaw=bike.transform.eulerAngles.y;initialized=true;Physics.SyncTransforms();
        }
        CharacterController Body(string label,float radius,float height)
        {
            GameObject body=new GameObject(label);body.transform.SetParent(transform,false);CharacterController controller=body.AddComponent<CharacterController>();
            controller.radius=radius;controller.height=height;controller.center=Vector3.up*(height*0.5f+0.04f);controller.stepOffset=0.24f;controller.slopeLimit=43;return controller;
        }
        public void SetTouchSteer(float n){touchSteer=RideRules.Finite(n)?Mathf.Clamp(n,-1,1):0;}
        public void SetTouchThrottle(float n){touchGas=RideRules.Finite(n)?Mathf.Clamp01(n):0;}
        public void SetTouchBrake(float n){touchBrake=RideRules.Finite(n)?Mathf.Clamp01(n):0;}
        public void SetTouchMove(Vector2 n){touchMove=RideRules.Finite(n.x)&&RideRules.Finite(n.y)?Vector2.ClampMagnitude(n,1):Vector2.zero;}
        public void AddLook(Vector2 delta){if(Controllable&&RideRules.Finite(delta.x)&&RideRules.Finite(delta.y))look+=Vector2.ClampMagnitude(delta,200);}
        void ClearInput(){touchSteer=touchGas=touchBrake=0;touchMove=look=Vector2.zero;speed=0;mouseReady=false;}
        void Update()
        {
            if(!initialized)return;
            if(!Controllable){ClearInput();return;}
            float dt=Mathf.Min(Time.deltaTime,0.05f);Vector2 key=new Vector2((Input.GetKey(KeyCode.D)?1:0)-(Input.GetKey(KeyCode.A)?1:0),(Input.GetKey(KeyCode.W)?1:0)-(Input.GetKey(KeyCode.S)?1:0));
            if(mouseReady&&Input.GetMouseButton(1))look+=(Vector2)(Input.mousePosition-lastMouse);lastMouse=Input.mousePosition;mouseReady=true;
            yaw+=look.x*0.14f;pitch=Mathf.Clamp(pitch-look.y*0.1f,7,48);look=Vector2.zero;
            if(IsRiding)
            {
                float gas=Mathf.Max(touchGas,key.y>0?1:0),brake=Mathf.Max(touchBrake,key.y<0?1:0);if(brake>0)gas=0;
                speed=Mathf.MoveTowards(speed,brake>0?0:gas>0?13:0,dt*(brake>0?9:gas>0?3.2f:0.9f));
                float steer=Mathf.Clamp(key.x+touchSteer,-1,1);bike.transform.Rotate(0,steer*Mathf.Min(speed/5,1)*38*dt,0);
                bikeFall=bike.isGrounded?-2:bikeFall-22*dt;CollisionFlags hit=bike.Move((bike.transform.forward*speed+Vector3.up*bikeFall)*dt);if((hit&CollisionFlags.Sides)!=0)speed=0;
                front.Rotate(Vector3.right,speed*dt/0.32f*Mathf.Rad2Deg,Space.Self);rear.Rotate(Vector3.right,speed*dt/0.32f*Mathf.Rad2Deg,Space.Self);bars.localRotation=Quaternion.Euler(0,steer*18,0);
                yaw=Mathf.LerpAngle(yaw,bike.transform.eulerAngles.y,dt*1.4f);
            }
            else
            {
                Vector2 move=Vector2.ClampMagnitude(key+touchMove,1);Vector3 direction=Quaternion.Euler(0,yaw,0)*new Vector3(move.x,0,move.y);
                if(direction.sqrMagnitude>0.01f)walker.transform.rotation=Quaternion.Slerp(walker.transform.rotation,Quaternion.LookRotation(direction),dt*10);
                walkFall=walker.isGrounded?-2:walkFall-22*dt;walker.Move((direction*3.8f+Vector3.up*walkFall)*dt);
                person.transform.localRotation=Quaternion.Euler(0,0,Mathf.Sin(Time.time*7)*move.magnitude*1.4f);
            }
            world.Follow(Meters);
            if(Active.position.y<TrailPath.Position(Meters).y-8)ReturnToCheckpoint();
            if(Input.GetKeyDown(KeyCode.F))TryDismountMount();if(Input.GetKeyDown(KeyCode.E))TryDiscover();if(Input.GetKeyDown(KeyCode.R))ReturnToCheckpoint();
        }
        void LateUpdate()
        {
            if(!initialized||externalCamera)return;Vector3 pivot=Active.position+Vector3.up*1.35f;
            if(title)
            {
                float orbit=bike.transform.eulerAngles.y-38+Mathf.Sin(Time.unscaledTime*0.13f)*7;
                viewRig.Follow(ViewCamera,bike.transform.position+Vector3.up*0.9f,Quaternion.Euler(12,orbit,0),9,bike.transform,walker.transform,Time.unscaledDeltaTime);return;
            }
            viewRig.Follow(ViewCamera,pivot,Quaternion.Euler(pitch,yaw,0),IsRiding?6.3f:4.5f,bike.transform,walker.transform,Time.deltaTime);
        }
        public bool TryDismountMount()
        {
            if(!Controllable)return false;
            if(IsRiding)
            {
                float s=Station(bike.transform.position),lane=Lane(bike.transform.position);
                if(!RideRules.CanDismount(speed,s,lane)){Notify("Tấp vào sân nghỉ bên phải và dừng xe để xuống.");return false;}
                walker.gameObject.SetActive(true);PlaceWalker(s,Mathf.Clamp(lane+(lane>5.2f?-1.0f:1.0f),3.5f,6.3f));seated.gameObject.SetActive(false);IsRiding=false;
            }
            else
            {
                if(!RideRules.CanMount(Vector3.Distance(walker.transform.position,bike.transform.position))){Notify("Lại gần chiếc xe để tiếp tục hành trình.");return false;}
                walker.gameObject.SetActive(false);seated.gameObject.SetActive(true);IsRiding=true;yaw=bike.transform.eulerAngles.y;
            }
            ClearInput();viewRig.Snap();Snapshot();if(Changed!=null)Changed();return true;
        }
        public bool TryDiscover()
        {
            if(!Controllable||IsRiding){Notify("Đi bộ đến biển nhỏ trong sân nghỉ để ghi dấu.");return false;}
            for(int i=0;i<RideRules.Stops.Length;i++)
            {
                float distance=Vector3.Distance(walker.transform.position,TrailPath.RoadPoint(RideRules.Stops[i],5.7f));if(distance>3)continue;
                if(state.visited.Contains(RideRules.Stamps[i])){Notify("Một nơi quen trên đường — dấu của bạn vẫn được giữ.");return true;}
                if(!RideRules.Discover(state,i,false,distance)){Notify("Hãy ghé những điểm nghỉ theo thứ tự của chuyến đi.");return false;}
                Notify(new[]{"Dấu đồi chè — gió mát mang hương lá non.","Dấu khúc mây — nhìn thung lũng xanh lùi xa.","Dấu cổng làng — đã đến nơi, hãy thong thả nghỉ chân."}[i]);Snapshot();if(Changed!=null)Changed();return true;
            }
            Notify("Đến gần biển chỉ dẫn trong sân nghỉ nhé.");return false;
        }
        public void ReturnToCheckpoint()
        {
            if(!Controllable)return;float s=RideRules.Checkpoint(Meters);world.WarmStart(s,palette);PositionBike(s,s>8?4.8f:1.2f);
            if(!IsRiding)PlaceWalker(s,s>8?5.8f:2.0f);ClearInput();viewRig.Snap();Snapshot();if(Changed!=null)Changed();Notify("Đã trở lại điểm nghỉ đã qua; các dấu khám phá được giữ.");
        }
        public void SetPaused(bool value){paused=value;ClearInput();if(viewRig!=null)viewRig.Snap();}
        public void SetMapPresentation(bool value){externalCamera=value;if(viewRig!=null)viewRig.Snap();if(!value&&ViewCamera!=null)ViewCamera.fieldOfView=57;}
        public void ShowTitleView(bool value){title=value;ClearInput();if(viewRig!=null)viewRig.Snap();}
        public void SetBikeColor(int color)
        {
            state.options.bikeColor=Mathf.Clamp(color,0,2);if(!initialized)return;Destroy(bikeModel);bikeModel=RideModel.Bike(bike.transform,palette,state.options.bikeColor,out front,out rear,out bars);if(Changed!=null)Changed();
        }
        void PositionBike(float s,float lane){bike.enabled=false;bike.transform.SetPositionAndRotation(TrailPath.RoadPoint(s,lane)+Vector3.up*0.15f,Quaternion.LookRotation(TrailPath.Forward(s)));bike.enabled=true;bikeFall=0;speed=0;}
        void PlaceWalker(float s,float lane){walker.enabled=false;walker.transform.position=TrailPath.RoadPoint(s,lane)+Vector3.up*0.15f;walker.enabled=true;walkFall=0;}
        void Snapshot(){if(!initialized)return;state.meters=Station(bike.transform.position);state.lane=Lane(bike.transform.position);}
        float Station(Vector3 point){float s=Mathf.Clamp(point.z,0,1600);for(int i=0;i<5;i++){Vector3 t=TrailPath.Forward(s);s=Mathf.Clamp(s+Vector3.Dot(point-TrailPath.Position(s),t)*Mathf.Abs(t.z),0,1600);}return s;}
        float Lane(Vector3 point){float s=Station(point);return Vector3.Dot(point-TrailPath.Position(s),TrailPath.Right(s));}
        void Notify(string text){if(Message!=null)Message(text);}
        void OnApplicationFocus(bool focus){unfocused=!focus;ClearInput();if(viewRig!=null)viewRig.Snap();}
        void OnApplicationPause(bool suspended){unfocused=suspended;ClearInput();if(viewRig!=null)viewRig.Snap();}
    }
}
