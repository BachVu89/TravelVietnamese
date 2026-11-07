using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    public sealed class PassGame : MonoBehaviour
    {
        public Material RoadMaterial,ShoulderMaterial,RockMaterial,FoliageMaterial;
        public GameObject BikeVisualPrefab,WalkerVisualPrefab,TreePrefab;
        public GameObject RockPrefab,FernPrefab,BananaPrefab;
        public GameObject BroadleafPrefab,PinePrefab,BushPrefab,RiderVisualPrefab;
        public bool ScenicQuality=true,ForceTouchControls=false;
        public float RidingCameraDistance=7,WalkingCameraDistance=5,CameraFieldOfView=69;
        public bool BuildOnAwake=true;
        public PassBike Bike {get;private set;}
        public PassWalker Walker {get;private set;}
        public JourneyState State {get;private set;}
        public bool Riding {get;private set;}
        PassCameraRig cameraRig;PassInput controls;Camera view;float orbitYaw,pitch=16,autosave;bool initialized,allowSave=true,focused=true;
        string message=""; GameObject bikeVisual,riderVisual;
        public void Build()
        {
            if(initialized)return;initialized=true;
            State=PassJournal.Load(out message);allowSave=string.IsNullOrEmpty(message);
            GameObject road=new GameObject("Procedural pass — illustrative, not GIS");road.transform.SetParent(transform,false);road.AddComponent<PassRoad>().Build(RoadMaterial,ShoulderMaterial,RockMaterial,FoliageMaterial,ScenicQuality);
            GameObject bike=new GameObject("Original arcade motorbike");bike.transform.SetParent(transform,false);Bike=bike.AddComponent<PassBike>();Bike.Place(State.BikeS,State.BikeLane);
            bikeVisual=Visual(bike.transform,BikeVisualPrefab,true);
            if(RiderVisualPrefab!=null){riderVisual=Instantiate(RiderVisualPrefab,bike.transform);riderVisual.transform.localPosition=Vector3.zero;foreach(Collider collider in riderVisual.GetComponentsInChildren<Collider>())collider.enabled=false;}
            else {riderVisual=new GameObject("Original rider silhouette");riderVisual.transform.SetParent(bike.transform,false);
            Primitive(riderVisual,PrimitiveType.Cube,new Vector3(0,1.45f,-0.12f),new Vector3(0.46f,0.65f,0.3f));
            Primitive(riderVisual,PrimitiveType.Sphere,new Vector3(0,1.99f,-0.04f),Vector3.one*0.48f);
            foreach(float side in new float[]{-1,1}){Primitive(riderVisual,PrimitiveType.Cube,new Vector3(side*0.28f,1.15f,0.23f),new Vector3(0.12f,0.12f,0.65f));Primitive(riderVisual,PrimitiveType.Cube,new Vector3(side*0.26f,0.77f,-0.1f),new Vector3(0.17f,0.65f,0.19f));}}
            GameObject walker=new GameObject("An — walking");walker.transform.SetParent(transform,false);Walker=walker.AddComponent<PassWalker>();Visual(walker.transform,WalkerVisualPrefab,false);
            Riding=true;Walker.SetActive(false);
            if(!State.Riding && PassRules.CanDismount(0,State.BikeS,State.BikeLane))ToggleVehicle();
            controls=gameObject.AddComponent<PassInput>();
            GameObject cameraObject=new GameObject("Third person camera");view=cameraObject.AddComponent<Camera>();cameraRig=cameraObject.AddComponent<PassCameraRig>();view.fieldOfView=Mathf.Clamp(CameraFieldOfView,45,85);view.farClipPlane=850;view.nearClipPlane=0.12f;
            if(Camera.main!=null && Camera.main!=view)Camera.main.enabled=false;cameraObject.tag="MainCamera";
            orbitYaw=Bike.transform.eulerAngles.y;
            for(int i=0;i<2;i++)
            {
                GameObject marker=GameObject.CreatePrimitive(PrimitiveType.Cylinder);marker.name=PassRules.StopIds[i];marker.transform.position=PassRoute.At(PassRules.StopDistances[i],10)+Vector3.up;
                marker.transform.localScale=new Vector3(0.5f,1,0.5f);marker.GetComponent<Renderer>().sharedMaterial=ShoulderMaterial;
            }
            if(!ScenicQuality && TreePrefab!=null)for(int i=0;i<140;i++){float s=i*5.25f;float side=i%2==0?-1:1;float lane=side*(18+(i%9)*3);Vector3 p=PassRoute.At(s,lane);p.y+=(Mathf.Abs(lane)-4.25f)*(side<0?0.72f:-0.55f);Instantiate(TreePrefab,p,Quaternion.Euler(0,(i*137)%360,0),transform);}
            if(ScenicQuality)road.AddComponent<PassLandscape>().Build(RockMaterial,FoliageMaterial,BroadleafPrefab,PinePrefab,BushPrefab,RockPrefab);
            Decorations();
            RenderSettings.fog=true;RenderSettings.fogMode=FogMode.Exponential;RenderSettings.fogDensity=0.004f;RenderSettings.fogColor=new Color(0.65f,0.71f,0.7f);
            Physics.SyncTransforms();
        }

        void Decorations()
        {
            for(int i=0;i<100;i++)
            {
                float s=10+i*7.3f;float side=i%2==0?-1:1;float lane=side*(side<0?7+(i%5)*2:18+(i%5)*3);
                GameObject prefab=i%3==0?RockPrefab:(i%3==1?FernPrefab:BananaPrefab);if(prefab==null)continue;
                Vector3 p=ScenicQuality?PassLandscape.SurfacePoint(s,lane):PassRoute.At(s,lane);if(!ScenicQuality)p.y+=(Mathf.Abs(lane)-4.25f)*(side<0?0.72f+Mathf.Sin(s*0.07f)*0.08f:-0.55f);
                GameObject decoration=Instantiate(prefab,p,Quaternion.Euler(0,(i*137)%360,0),transform);
                foreach(Collider collider in decoration.GetComponentsInChildren<Collider>())collider.enabled=false;
            }
        }
        void Awake(){if(BuildOnAwake)Build();}
        void Update()
        {
            if(!initialized)return;
            controls.Poll();bool blocked=!focused;
            Bike.Blocked=blocked;Walker.Blocked=blocked;if(blocked)return;
            float dt=Mathf.Min(Time.deltaTime,0.05f);
            orbitYaw+=controls.Look.x*0.16f;pitch=Mathf.Clamp(pitch-controls.Look.y*0.12f,5,55);
            Bike.Drive=new Vector2(Mathf.Clamp(controls.Move.x,-1,1),controls.Brake>0?-controls.Brake:controls.Gas);
            Walker.Move=controls.Move;Walker.CameraYaw=orbitYaw;
            Bike.Step(dt);if(!Riding)Walker.Step(dt);
            if(controls.MountPressed)ToggleVehicle();if(controls.InspectPressed)Inspect();if(controls.ResetPressed)ResetToCheckpoint();
            Transform active=Riding?Bike.transform:Walker.transform;
            if(active.position.y<PassRoute.Point(PassRoute.Distance(active.position)).y-10)ResetToCheckpoint();
            autosave+=dt;if(autosave>5 && allowSave){autosave=0;Save(false);}
        }
        void LateUpdate()
        {
            if(!initialized)return;
            Transform active=Riding?Bike.transform:Walker.transform;
            if(Riding && controls.Look.sqrMagnitude<0.01f)orbitYaw=Mathf.LerpAngle(orbitYaw,Bike.transform.eulerAngles.y,Time.deltaTime*1.8f);
            Vector3 target=active.position+Vector3.up*1.6f;
            Quaternion rotation=Quaternion.Euler(pitch,orbitYaw,0);
            cameraRig.Apply(view,target,rotation,Riding?Mathf.Max(3,RidingCameraDistance):Mathf.Max(3,WalkingCameraDistance),Bike.transform,Walker.transform,Time.deltaTime);
        }
        public bool ToggleVehicle()
        {
            if(Riding)
            {
                if(!PassRules.CanDismount(Bike.Speed,PassRoute.Distance(Bike.transform.position),PassRoute.Lane(Bike.transform.position))){message="Dừng xe trong vịnh dừng (về bên phải) rồi xuống xe.";return false;}
                Riding=false;Bike.Riding=false;riderVisual.SetActive(false);Walker.SetActive(true);Walker.Place(SafeWalkExitPosition());
            }
            else
            {
                if(!PassRules.CanMount(Vector3.Distance(Walker.transform.position,Bike.transform.position))){message="Đi lại gần xe trong phạm vi 3 m để lên xe.";return false;}
                Riding=true;Bike.Riding=true;riderVisual.SetActive(true);Walker.SetActive(false);orbitYaw=Bike.transform.eulerAngles.y;
            }
            if(controls!=null)controls.Clear();if(cameraRig!=null)cameraRig.RequestSnap();if(allowSave && controls!=null)Save(false);return true;
        }
        Vector3 SafeWalkExitPosition()
        {
            float station=PassRoute.Distance(Bike.transform.position);
            float lane=PassRoute.Lane(Bike.transform.position);
            // Keep the 0.33 m walking capsule inside the bay's 13 m outer guardrail.
            // At the outer edge dismount inward; elsewhere use the free side beside the bike.
            float exitLane=lane+(lane>10?-1.3f:1.3f);
            bool inBay=PassRules.IsStopZone(station,lane);
            exitLane=inBay?Mathf.Clamp(exitLane,4.8f,11.6f):Mathf.Clamp(exitLane,-3.5f,PassRoute.Edge(station)-0.7f);
            return PassRoute.At(station,exitLane)+Vector3.up*0.2f;
        }
        public bool Inspect()
        {
            if(Riding){message="Đỗ xe và xuống xe để khám phá.";return false;}
            for(int i=0;i<2;i++)
            {
                float distance=Vector3.Distance(Walker.transform.position,PassRoute.At(PassRules.StopDistances[i],10));
                if(distance>3.7f)continue;
                if(State.Visited.Contains(PassRules.StopIds[i])){message=StopText(i);return true;}
                if(!PassRules.TryVisit(State,PassRules.StopIds[i],false,distance)){message="Khám phá Ban công mây trước khi đến Trạm thung lũng.";return false;}
                message=StopText(i);if(allowSave)Save(false);return true;
            }
            message="Đi gần cột mốc trong vịnh dừng (3.7 m).";return false;
        }
        static string StopText(int i){return i==0?"Ban công mây: nhìn những tầng cây đậm gần, nhạt xa trong màn sương. Điểm dừng minh họa, không phải dữ liệu khảo sát Khánh Lê.":"Trạm thung lũng: quan sát sườn núi và con đường uốn cong phía dưới. Đã hoàn thành hai dấu khám phá trong cảnh mẫu, không phải bản đồ thực địa.";}
        public void ResetToCheckpoint()
        {
            Vector3 p=Riding?Bike.transform.position:Walker.transform.position;float checkpoint=PassRules.LatestPassedCheckpoint(PassRoute.Distance(p));
            Bike.Place(Mathf.Max(5,checkpoint),checkpoint>0?8:1.7f);
            if(!Riding)Walker.Place(SafeWalkExitPosition());
            controls.Clear();if(cameraRig!=null)cameraRig.RequestSnap();message="Đã về điểm an toàn đã đi qua; giữ các dấu khám phá.";if(allowSave)Save(false);
        }
        public bool Save(bool explicitSave=true)
        {
            State.BikeS=PassRoute.Distance(Bike.transform.position);State.BikeLane=PassRoute.Lane(Bike.transform.position);State.Riding=Riding;
            string error;bool ok=PassJournal.Save(State,out error);if(explicitSave && ok){allowSave=true;message="Đã lưu offline trên thiết bị.";}if(!ok)message=error;return ok;
        }
        void OnApplicationFocus(bool value){focused=value;if(cameraRig!=null)cameraRig.RequestSnap();if(!value && initialized){controls.Clear();Bike.Stop();if(allowSave)Save(false);}}
        void OnApplicationPause(bool paused){focused=!paused;if(cameraRig!=null)cameraRig.RequestSnap();if(paused && initialized){controls.Clear();Bike.Stop();if(allowSave)Save(false);}}
        void OnApplicationQuit(){if(initialized && allowSave)Save(false);}
        void OnGUI()
        {
            if(!initialized)return;
            Matrix4x4 oldMatrix=GUI.matrix;Color oldBackground=GUI.backgroundColor;
            float scale=Mathf.Max(1,Screen.height/900f);GUI.matrix=Matrix4x4.TRS(Vector3.zero,Quaternion.identity,Vector3.one*scale);
            float width=Screen.width/scale,height=Screen.height/scale;
            bool touch=Application.isMobilePlatform || ForceTouchControls;float actionHeight=touch?44:29;
            GUI.backgroundColor=new Color(0.12f,0.19f,0.17f,0.58f);
            GUI.Box(new Rect(12,10,Mathf.Min(width-24,780),touch?90:72),"");
            GUI.Label(new Rect(24,16,750,24),"DỌC MIỀN VIỆT  ·  "+(Riding?(Bike.Speed*3.6f).ToString("0")+" km/h":"ĐI BỘ")+"  ·  "+State.Visited.Count+"/2 dấu  ·  "+PassRoute.Distance(Bike.transform.position).ToString("0")+" / ≈750 m cảnh");
            if(GUI.Button(new Rect(24,44,130,actionHeight),Riding?"Xuống xe [F]":"Lên xe [F]"))ToggleVehicle();
            if(GUI.Button(new Rect(161,44,130,actionHeight),"Khám phá [E]"))Inspect();
            if(GUI.Button(new Rect(298,44,145,actionHeight),"Điểm an toàn [R]"))ResetToCheckpoint();
            if(GUI.Button(new Rect(450,44,75,actionHeight),"Lưu"))Save();
            string footer=string.IsNullOrEmpty(message)?"WASD: lái / đi bộ · W: ga · S: phanh · Chuột phải: camera · Đỗ bên phải để xuống xe":message;
            GUI.Box(new Rect(18,height-48,Mathf.Min(width-36,1050),35),footer);
            if(touch)
            {
                // Match PassInput's normalised touch zones, expressed here in GUI coordinates.
                GUI.Box(new Rect(width*0.035f,height*0.72f,width*0.19f,height*0.14f),"CẦN TRÁI\nLái / đi bộ");
                GUI.Box(new Rect(width*0.70f,height*0.70f,width*0.14f,height*0.16f),"PHANH");
                GUI.Box(new Rect(width*0.86f,height*0.70f,width*0.13f,height*0.16f),"GA");
            }
            GUI.backgroundColor=oldBackground;GUI.matrix=oldMatrix;
        }
        GameObject Visual(Transform parent,GameObject prefab,bool bike)
        {
            if(prefab!=null){GameObject instance=Instantiate(prefab,parent);instance.transform.localPosition=Vector3.zero;return instance;}
            GameObject root=new GameObject(bike?"Original motorbike placeholder":"Original walking placeholder");root.transform.SetParent(parent,false);
            Primitive(root,PrimitiveType.Cube,bike?new Vector3(0,0.9f,0):new Vector3(0,1.1f,0),bike?new Vector3(0.45f,0.3f,1.2f):new Vector3(0.45f,0.65f,0.3f));
            if(bike)foreach(float z in new float[]{-0.7f,0.7f}){GameObject wheel=Primitive(root,PrimitiveType.Cylinder,new Vector3(0,0.36f,z),new Vector3(0.65f,0.12f,0.65f));wheel.transform.localRotation=Quaternion.Euler(0,0,90);}
            else{Primitive(root,PrimitiveType.Sphere,new Vector3(0,1.65f,0),Vector3.one*0.45f);foreach(float x in new float[]{-0.13f,0.13f})Primitive(root,PrimitiveType.Cube,new Vector3(x,0.42f,0),new Vector3(0.18f,0.8f,0.2f));}
            return root;
        }
        GameObject Primitive(GameObject parent,PrimitiveType type,Vector3 position,Vector3 size)
        {
            GameObject part=GameObject.CreatePrimitive(type);part.transform.SetParent(parent.transform,false);part.transform.localPosition=position;part.transform.localScale=size;part.GetComponent<Renderer>().sharedMaterial=ShoulderMaterial;
            Collider collider=part.GetComponent<Collider>();collider.enabled=false;Destroy(collider);return part;
        }
    }
}
