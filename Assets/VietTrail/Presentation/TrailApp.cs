using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;
using VietTrail.Core;
using VietTrail.Gameplay;
using VietTrail.World;
using VietTrail.Rendering;
namespace VietTrail.Presentation
{
    /// <summary>Fresh offline application and UI. No legacy save file is read.</summary>
    [DefaultExecutionOrder(200)]
    public sealed class TrailApp : MonoBehaviour
    {
        [Serializable] sealed class Region {public string id,name,status,subtitle,note,provinceId;public bool sceneAvailable;}
        [Serializable] sealed class Registry {public Region[] provinces,tourismChapters,representativeIslands;public string snapshotDate,snapshotNote,coverageNote;}
        Texture2D ownedPalette;
        RiderDirector rider;SegmentHost world;JourneyMapView map;Material paint;Light sun;VisualElement root,page,hud,touch;
        Label speed,progress,notification;VisualElement lookPad;readonly Dictionary<int,Vector2> pointers=new Dictionary<int,Vector2>();Vector2 downPosition;float pinchDistance,gestureDistance;Registry registry;string screen="title",notice="";bool allowSave=true;float saveTimer;
        string SavePath {get{return Path.Combine(Application.persistentDataPath,"viettrail-painterly-v1.json");}}
        readonly Color ink=new Color(0.16f,0.25f,0.22f),cream=new Color(0.98f,0.95f,0.85f),green=new Color(0.22f,0.36f,0.29f);
        void Awake()
        {
            Material resource=Resources.Load<Material>("Theme/PainterlyWorld");
            if(resource!=null)paint=new Material(resource);else{Shader shader=Shader.Find("VietTrail/Painterly Lit");if(shader==null){Debug.LogError("Painterly shader missing; run project setup.");enabled=false;return;}paint=new Material(shader);}
            bool ownsPalette;
            Texture2D paletteTexture=PainterlyPalette.LoadOrCreate(out ownsPalette);
            if(ownsPalette)ownedPalette=paletteTexture;
            paint.SetTexture("_Palette",paletteTexture);
            Material sky=Resources.Load<Material>("Theme/PainterlySky");if(sky==null){Shader shader=Shader.Find("VietTrail/Painterly Sky");if(shader!=null)sky=new Material(shader);}if(sky!=null)RenderSettings.skybox=sky;
            RenderSettings.ambientMode=AmbientMode.Flat;RenderSettings.ambientLight=new Color(0.67f,0.72f,0.62f);RenderSettings.fog=false;
            GameObject lightObject=new GameObject("Afternoon sun");lightObject.transform.SetParent(transform,false);sun=lightObject.AddComponent<Light>();sun.type=LightType.Directional;sun.transform.rotation=Quaternion.Euler(22,-32,0);sun.color=new Color(1,0.9f,0.74f);sun.intensity=1.05f;sun.shadows=LightShadows.Soft;
            GameObject terrain=new GameObject("Streamed mountain chapter");terrain.transform.SetParent(transform,false);world=terrain.AddComponent<SegmentHost>();
            TextAsset regions=Resources.Load<TextAsset>("Regions");if(regions!=null)registry=JsonUtility.FromJson<Registry>(regions.text);
            gameObject.AddComponent<SharedPainterlyLook>().Initialize(null,paint);
            JourneyState state=Load();CreateRider(state);
            GameObject mapObject=new GameObject("Illustrative journey map");mapObject.transform.SetParent(transform,false);map=mapObject.AddComponent<JourneyMapView>();map.Initialize(paint);map.ChapterSelected+=SelectChapter;map.Show(false);
            BuildDocument();Show("title");
        }
        void CreateRider(JourneyState state)
        {
            if(rider!=null)Destroy(rider.gameObject);
            GameObject actor=new GameObject("Ride and walk");actor.transform.SetParent(transform,false);rider=actor.AddComponent<RiderDirector>();rider.Initialize(paint,world,state);rider.Changed+=OnChanged;rider.Message+=Notify;
            SharedPainterlyLook.ConfigureCamera(rider.ViewCamera,gameObject.layer);ApplyOptions();
        }
        JourneyState Load()
        {
            if(!File.Exists(SavePath))return new JourneyState();
            try{JourneyState state=JsonUtility.FromJson<JourneyState>(File.ReadAllText(SavePath));if(state==null||state.version!=1)throw new InvalidDataException("Unsupported journey version");return RideRules.Normalize(state);}
            catch(Exception error){allowSave=false;notice="Bản lưu chưa đọc được. Tệp cũ được giữ; chọn hành trình mới để bắt đầu lại. "+error.GetType().Name;return new JourneyState();}
        }
        bool Save()
        {
            if(!allowSave||rider==null)return false;
            try
            {
                Directory.CreateDirectory(Application.persistentDataPath);string temp=SavePath+".tmp";
                using(FileStream file=new FileStream(temp,FileMode.Create,FileAccess.Write,FileShare.None))using(StreamWriter writer=new StreamWriter(file)){writer.Write(JsonUtility.ToJson(RideRules.Normalize(rider.State)));writer.Flush();file.Flush(true);}
                if(File.Exists(SavePath))File.Replace(temp,SavePath,SavePath+".bak");else File.Move(temp,SavePath);return true;
            }
            catch(Exception error){Notify("Chưa lưu được. Thử Lưu trước khi thoát. "+error.GetType().Name);return false;}
        }
        void OnChanged(){Save();}
        void Notify(string text){notice=text;if(notification!=null)notification.text=text;}
        void ApplyOptions(){if(rider!=null){QualitySettings.shadows=rider.State.options.quality==0?ShadowQuality.Disable:ShadowQuality.All;AudioListener.volume=Mathf.Clamp01(rider.State.options.sfx);}}
        void BuildDocument()
        {
            UIDocument document=gameObject.AddComponent<UIDocument>();PanelSettings panel=ScriptableObject.CreateInstance<PanelSettings>();panel.scaleMode=PanelScaleMode.ScaleWithScreenSize;panel.referenceResolution=new Vector2Int(1280,720);panel.match=0.5f;document.panelSettings=panel;
            root=document.rootVisualElement;root.style.flexGrow=1;root.style.unityFont=Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");root.style.color=ink;
            BuildLookPad();
            page=new VisualElement();page.style.position=Position.Absolute;page.style.left=24;page.style.top=24;page.style.bottom=24;page.style.width=430;root.Add(page);
            hud=new VisualElement();hud.style.position=Position.Absolute;hud.style.left=20;hud.style.right=20;hud.style.top=16;hud.style.flexDirection=FlexDirection.Row;hud.style.justifyContent=Justify.SpaceBetween;root.Add(hud);
            touch=new VisualElement();touch.style.position=Position.Absolute;touch.style.left=0;touch.style.right=0;touch.style.bottom=0;touch.style.height=220;touch.pickingMode=PickingMode.Ignore;root.Add(touch);
            notification=Label(notice,14);notification.style.position=Position.Absolute;notification.style.left=24;notification.style.bottom=8;notification.style.right=24;notification.style.backgroundColor=new Color(0.98f,0.95f,0.85f,0.82f);notification.pickingMode=PickingMode.Ignore;root.Add(notification);
        }
        void BuildLookPad()
        {
            lookPad=new VisualElement();lookPad.style.position=Position.Absolute;lookPad.style.left=new Length(36,LengthUnit.Percent);lookPad.style.right=0;lookPad.style.top=125;lookPad.style.bottom=180;root.Add(lookPad);
            lookPad.RegisterCallback<PointerDownEvent>(e=>{if(screen!="ride"&&screen!="map")return;Vector2 p=e.position;pointers[e.pointerId]=p;downPosition=p;gestureDistance=0;lookPad.CapturePointer(e.pointerId);pinchDistance=PointerDistance();e.StopPropagation();});
            lookPad.RegisterCallback<PointerMoveEvent>(e=>
            {
                Vector2 previous;if(!pointers.TryGetValue(e.pointerId,out previous))return;Vector2 now=e.position,delta=now-previous;pointers[e.pointerId]=now;gestureDistance+=delta.magnitude;
                if(screen=="map"&&pointers.Count>=2){float distance=PointerDistance();if(pinchDistance>0)map.Zoom((distance-pinchDistance)*0.025f);pinchDistance=distance;}
                else if(screen=="map")map.Orbit(delta);else if(screen=="ride"&&!(e.pointerType==UnityEngine.UIElements.PointerType.mouse&&Input.GetMouseButton(1)))rider.AddLook(delta);e.StopPropagation();
            });
            lookPad.RegisterCallback<PointerUpEvent>(e=>
            {
                if(screen=="map"&&pointers.Count==1&&gestureDistance<7&&root.resolvedStyle.width>0&&root.resolvedStyle.height>0)
                    map.TrySelect(rider.ViewCamera,new Vector2(e.position.x/root.resolvedStyle.width*Screen.width,(1-e.position.y/root.resolvedStyle.height)*Screen.height));
                pointers.Remove(e.pointerId);lookPad.ReleasePointer(e.pointerId);pinchDistance=0;e.StopPropagation();
            });
            lookPad.RegisterCallback<PointerCancelEvent>(e=>{pointers.Remove(e.pointerId);lookPad.ReleasePointer(e.pointerId);pinchDistance=0;});
            lookPad.RegisterCallback<PointerCaptureOutEvent>(e=>{pointers.Remove(e.pointerId);pinchDistance=0;});
            lookPad.RegisterCallback<WheelEvent>(e=>{if(screen=="map"){map.Zoom(-e.delta.y*0.12f);e.StopPropagation();}});
        }
        float PointerDistance(){if(pointers.Count<2)return 0;Vector2 a=Vector2.zero;bool first=true;foreach(Vector2 p in pointers.Values){if(first){a=p;first=false;}else return Vector2.Distance(a,p);}return 0;}
        void ReleaseGesture(){if(lookPad==null)return;var ids=new List<int>(pointers.Keys);foreach(int id in ids)lookPad.ReleasePointer(id);pointers.Clear();pinchDistance=gestureDistance=0;}
        Label Label(string text,int size=18){Label label=new Label(text);label.style.fontSize=size;label.style.whiteSpace=WhiteSpace.Normal;label.style.marginBottom=12;return label;}
        Button Button(string text,Action action)
        {
            Button button=new Button(action){text=text};button.style.height=48;button.style.marginBottom=8;button.style.backgroundColor=green;button.style.color=cream;button.style.borderTopLeftRadius=9;button.style.borderBottomRightRadius=9;button.style.borderTopRightRadius=9;button.style.borderBottomLeftRadius=9;button.style.fontSize=17;button.style.unityTextAlign=TextAnchor.MiddleCenter;return button;
        }
        void Show(string destination)
        {
            screen=destination;ReleaseGesture();page.Clear();hud.Clear();touch.Clear();page.style.display=destination=="ride"?DisplayStyle.None:DisplayStyle.Flex;
            page.style.backgroundColor=new Color(0.98f,0.95f,0.85f,0.95f);page.style.paddingLeft=24;page.style.paddingRight=24;page.style.paddingTop=22;page.style.paddingBottom=20;
            rider.SetPaused(destination!="ride");rider.ShowTitleView(destination!="ride"&&destination!="map");rider.SetMapPresentation(destination=="map");map.Show(destination=="map");world.SetVegetationVisible(destination!="map");
            if(destination=="ride"){BuildHud();return;}
            page.Add(Label("PHƯỢT\nXUYÊN VIỆT",34));
            if(destination=="title")
            {
                page.Add(Label("Đi một chặng nhỏ. Mang về một câu chuyện.",21));page.Add(Label("Đường núi phía Bắc · 3 điểm nghỉ · Chơi offline"));
                page.Add(Button("Tiếp tục chuyến đi",()=>Show("ride")));page.Add(Button("Hành trình mới",()=>Show("new")));page.Add(Button("Bản đồ Việt Nam",()=>Show("map")));page.Add(Button("Gara của bạn",()=>Show("garage")));page.Add(Button("Cài đặt",()=>Show("settings")));if(!Application.isMobilePlatform)page.Add(Button("Thoát",()=>{Save();Application.Quit();}));
            }
            else if(destination=="new")
            {
                page.Add(Label("Bắt đầu chuyến đi mới?"));page.Add(Label("Vị trí và ba dấu của hành trình hiện tại sẽ được thay thế khi lưu."));page.Add(Button("Bắt đầu từ lối vào",()=>{allowSave=true;CreateRider(new JourneyState());Save();Show("ride");}));page.Add(Button("Giữ hành trình",()=>Show("title")));
            }
            else if(destination=="pause")
            {
                page.Add(Label("Nghỉ chân một lát",25));page.Add(Button("Tiếp tục",()=>Show("ride")));page.Add(Button("Lưu hành trình",()=>{if(Save())Notify("Đã lưu trên thiết bị.");}));page.Add(Button("Trở lại điểm nghỉ",()=>{Show("ride");rider.ReturnToCheckpoint();}));page.Add(Button("Bản đồ",()=>Show("map")));page.Add(Button("Về màn hình đầu",()=>{Save();Show("title");}));
            }
            else if(destination=="garage")
            {
                page.Add(Label("Chiếc xe thân quen",25));string[] colors={"Đỏ gạch","Xanh ô-liu","Xanh lam"};for(int i=0;i<3;i++){int c=i;page.Add(Button(colors[i]+(rider.State.options.bikeColor==i?" ✓":""),()=>{rider.SetBikeColor(c);Show("garage");}));}page.Add(Label("Xe số dáng cổ điển, mũ bảo hiểm và ba lô — hành trang cho một chuyến đi chậm."));Back();
            }
            else if(destination=="settings")
            {
                page.Add(Label("Cài đặt",25));Option("Nhạc",true);Option("Âm thanh",false);page.Add(Label("Chưa kèm bản nhạc có bản quyền; mức nhạc được lưu để dùng khi có audio."));page.Add(Button("Bóng đổ: "+(rider.State.options.quality==1?"Bật":"Tắt"),()=>{rider.State.options.quality=1-rider.State.options.quality;ApplyOptions();Save();Show("settings");}));Back();
            }
            else if(destination=="map")BuildMap();
            if(!string.IsNullOrEmpty(notice))page.Add(Label(notice,13));
        }
        void Back(){page.Add(Button("Trở lại",()=>Show("title")));}
        void Option(string title,bool music)
        {
            float value=music?rider.State.options.music:rider.State.options.sfx;page.Add(Label(title+" · "+Mathf.RoundToInt(value*100)+"%"));VisualElement row=new VisualElement();row.style.flexDirection=FlexDirection.Row;
            foreach(float step in new float[]{-0.1f,0.1f}){float delta=step;Button button=Button(step<0?"−":"+",()=>{if(music)rider.State.options.music=Mathf.Clamp01(value+delta);else rider.State.options.sfx=Mathf.Clamp01(value+delta);ApplyOptions();Save();Show("settings");});button.style.width=80;button.style.marginRight=12;row.Add(button);}page.Add(row);
        }
        void BuildMap()
        {
            page.Add(Label("Một dải Việt Nam",25));page.Add(Label("Bản đồ 3D minh họa để chọn chương; chưa phải địa hình khảo sát/DEM.",14));
            ScrollView scroll=new ScrollView();scroll.style.flexGrow=1;page.Add(scroll);
            if(registry!=null&&registry.tourismChapters!=null)foreach(Region entry in registry.tourismChapters){Region chapter=entry;scroll.Add(Button(chapter.name+(chapter.status=="demo"?" · Chương mẫu":" · Đang chuẩn bị"),()=>SelectChapter(chapter.id)));scroll.Add(Label(chapter.subtitle,13));}
            if(registry!=null){VisualElement provinces=new VisualElement();provinces.style.display=DisplayStyle.None;scroll.Add(Button("Danh mục "+(registry.provinces==null?0:registry.provinces.Length)+" tỉnh/thành · Xem tên",()=>provinces.style.display=provinces.style.display.value==DisplayStyle.None?DisplayStyle.Flex:DisplayStyle.None));scroll.Add(provinces);if(registry.provinces!=null)foreach(Region province in registry.provinces)provinces.Add(Label(province.name+" · cảnh đang chuẩn bị",13));if(registry.representativeIslands!=null)foreach(Region island in registry.representativeIslands)scroll.Add(Label(island.name+" · chưa có cảnh",13));}
            VisualElement navigation=new VisualElement();navigation.style.flexDirection=FlexDirection.Row;navigation.Add(Button("↶",()=>map.Orbit(new Vector2(-45,0))));navigation.Add(Button("↷",()=>map.Orbit(new Vector2(45,0))));navigation.Add(Button("+",()=>map.Zoom(1)));navigation.Add(Button("−",()=>map.Zoom(-1)));page.Add(navigation);Back();
        }
        void SelectChapter(string id)
        {
            if(map!=null)map.SetFocus(id);
            if(id=="ha-giang")
            {
                page.Clear();page.Add(Label("Hà Giang",32));page.Add(Label("Chương mẫu đường núi phía Bắc. Tuyến sinh thủ tục lấy cảm hứng phong cảnh, không tái dựng một đèo thực địa."));page.Add(Button("Lên đường",()=>Show("ride")));page.Add(Button("Xem các chương",()=>Show("map")));
            }
            else Notify("Chương này đang chuẩn bị, chưa có cảnh chơi. Bạn có thể trở lại chương mẫu phía Bắc.");
        }
        void BuildHud()
        {
            VisualElement info=new VisualElement();info.style.backgroundColor=new Color(0.98f,0.95f,0.85f,0.88f);info.style.paddingLeft=16;info.style.paddingRight=16;speed=Label("",21);progress=Label("",14);info.Add(speed);info.Add(progress);hud.Add(info);
            VisualElement actions=new VisualElement();actions.style.flexDirection=FlexDirection.Row;actions.Add(Button("Xe / Đi bộ [F]",()=>rider.TryDismountMount()));actions.Add(Button("Ghi dấu [E]",()=>rider.TryDiscover()));actions.Add(Button("Nghỉ",()=>Show("pause")));hud.Add(actions);

            if(Application.isMobilePlatform)
            {
                VisualElement left=new VisualElement();left.style.position=Position.Absolute;left.style.left=24;left.style.bottom=30;left.style.flexDirection=FlexDirection.Row;touch.Add(left);
                Hold(left,"◀",()=>{rider.SetTouchSteer(-1);rider.SetTouchMove(Vector2.left);},()=>{rider.SetTouchSteer(0);rider.SetTouchMove(Vector2.zero);});Hold(left,"▲",()=>rider.SetTouchMove(Vector2.up),()=>rider.SetTouchMove(Vector2.zero));Hold(left,"▶",()=>{rider.SetTouchSteer(1);rider.SetTouchMove(Vector2.right);},()=>{rider.SetTouchSteer(0);rider.SetTouchMove(Vector2.zero);});
                VisualElement pedals=new VisualElement();pedals.style.position=Position.Absolute;pedals.style.right=24;pedals.style.bottom=30;pedals.style.flexDirection=FlexDirection.Row;touch.Add(pedals);Hold(pedals,"Phanh",()=>rider.SetTouchBrake(1),()=>rider.SetTouchBrake(0));Hold(pedals,"Ga",()=>rider.SetTouchThrottle(1),()=>rider.SetTouchThrottle(0));
            }
        }
        void Hold(VisualElement parent,string text,Action press,Action release)
        {
            Button button=Button(text,()=>{});button.style.width=85;button.style.height=70;button.RegisterCallback<PointerDownEvent>(e=>{button.CapturePointer(e.pointerId);press();e.StopPropagation();});button.RegisterCallback<PointerUpEvent>(e=>{release();button.ReleasePointer(e.pointerId);e.StopPropagation();});button.RegisterCallback<PointerCancelEvent>(e=>{release();button.ReleasePointer(e.pointerId);});button.RegisterCallback<PointerCaptureOutEvent>(e=>release());parent.Add(button);
        }
        void Update()
        {
            if(rider==null||root==null)return;if(Input.GetKeyDown(KeyCode.Escape))Show(screen=="ride"?"pause":"ride");
            if(screen=="ride"){speed.text=rider.IsRiding?rider.SpeedKmh.ToString("0")+" km/h":"Đi bộ";progress.text=(int)rider.Meters+" / 1600 m cảnh · "+rider.State.visited.Count+"/3 dấu";saveTimer+=Time.unscaledDeltaTime;if(saveTimer>5){saveTimer=0;Save();}}
        }
        void LateUpdate(){if(screen=="map"&&map!=null&&rider!=null)map.UpdateCamera(rider.ViewCamera);}
        void OnApplicationPause(bool paused){if(paused){ReleaseGesture();Save();}}
        void OnApplicationFocus(bool focused){if(!focused){ReleaseGesture();Save();}}
        void OnApplicationQuit(){Save();}
        void OnDestroy(){if(paint!=null)Destroy(paint);if(ownedPalette!=null)Destroy(ownedPalette);}

    }
}
