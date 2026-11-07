using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using TravelVietnamese.UnityPrototype;

namespace TravelVietnamese.Editor
{
    public static class PassScenicUpgrade
    {
        const string Root="Assets/TravelVietnamese";
        const string Output=Root+"/Generated/ScenicV3";
        [Serializable] sealed class Report {public Entry[] assets;}
        [Serializable] sealed class Entry {public string name;public string[] material_slots;}
        static bool Hdrp {get{return GraphicsSettings.defaultRenderPipeline!=null && GraphicsSettings.defaultRenderPipeline.GetType().Name.StartsWith("HD");}}
        static Color ColorFor(string name)
        {
            switch(name)
            {
                case "M_Forest_Bark":return new Color(.12f,.095f,.065f);
                case "M_Forest_LeafDeep":return new Color(.025f,.08f,.03f);
                case "M_Forest_LeafMid":return new Color(.045f,.14f,.05f);
                case "M_Forest_LeafSun":return new Color(.09f,.21f,.065f);
                case "M_Forest_PineNeedles":return new Color(.025f,.10f,.065f);
                case "TV_Rubber":return new Color(.025f,.03f,.028f);
                case "TV_Steel":return new Color(.32f,.36f,.34f);
                case "TV_OlivePaint":return new Color(.10f,.16f,.12f);
                case "TV_Leather":return new Color(.08f,.055f,.035f);
                case "TV_Lamp":return new Color(.84f,.72f,.45f);
                case "TV_TailLamp":return new Color(.48f,.025f,.012f);
                case "TV_Cloth":return new Color(.16f,.21f,.15f);
                case "TV_Boot":return new Color(.055f,.043f,.032f);
                case "TV_Helmet":return new Color(.12f,.15f,.13f);
                case "TV_Visor":return new Color(.025f,.038f,.04f);
                case "TV_Pack":return new Color(.24f,.20f,.13f);
                case "TV_Skin":return new Color(.40f,.27f,.19f);
                default:throw new InvalidOperationException("Unknown original material: "+name);
            }
        }
        static Material Palette(string name)
        {
            string path=Output+"/"+name+".mat";
            Material material=AssetDatabase.LoadAssetAtPath<Material>(path);if(material!=null)return material;
            Shader shader=Shader.Find(Hdrp?"HDRP/Lit":"Universal Render Pipeline/Lit");
            if(shader==null)throw new InvalidOperationException("Configure the render pipeline first.");
            material=new Material(shader){name=name,enableInstancing=true};
            material.SetColor("_BaseColor",ColorFor(name));
            // Forest leaves already have separated front/back geometry; keep back-face
            // culling instead of drawing both shells twice with a two-sided shader.
            bool metal=name=="TV_Steel";material.SetFloat("_Metallic",metal ? 0.75f : 0f);
            material.SetFloat("_Smoothness",metal ? 0.45f : ((name=="TV_Helmet"||name=="TV_Visor") ? 0.40f : 0.12f));
            AssetDatabase.CreateAsset(material,path);return material;
        }
        static GameObject Import(string folder,string reportFile,string name)
        {
            string reportPath=Root+"/Art/"+folder+"/"+reportFile;
            TextAsset text=AssetDatabase.LoadAssetAtPath<TextAsset>(reportPath);
            if(text==null)throw new InvalidOperationException("Missing provenance report: "+reportPath);
            Report report=JsonUtility.FromJson<Report>(text.text);Entry entry=null;
            foreach(Entry asset in report.assets)if(asset.name==name)entry=asset;
            if(entry==null)throw new InvalidOperationException("Asset absent from report: "+name);
            string source=Root+"/Art/"+folder+"/"+name+".fbx";
            ModelImporter importer=AssetImporter.GetAtPath(source) as ModelImporter;
            if(importer==null)throw new InvalidOperationException("FBX not imported: "+source);
            // Remap by source material name: FBX import may remove unused material slots.
            foreach(string slot in entry.material_slots)
                importer.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material),slot),Palette(slot));
            importer.SaveAndReimport();
            string path=Output+"/"+name+".prefab";
            GameObject existing=AssetDatabase.LoadAssetAtPath<GameObject>(path);if(existing!=null)return existing;
            GameObject model=AssetDatabase.LoadAssetAtPath<GameObject>(source);
            if(model==null)throw new InvalidOperationException("Model unavailable: "+source);
            GameObject container=new GameObject(name+"_Visual");
            GameObject instance=(GameObject)PrefabUtility.InstantiatePrefab(model);
            // Keep FBX unit/axis conversion on the child. Gameplay and instancing
            // rotate an identity wrapper, so import scale/orientation are not discarded.
            instance.transform.SetParent(container.transform,false);
            try
            {
                foreach(Collider collider in instance.GetComponentsInChildren<Collider>(true))UnityEngine.Object.DestroyImmediate(collider);
                if(instance.GetComponentsInChildren<MeshRenderer>(true).Length==0)throw new InvalidOperationException("No rendered mesh: "+name);
                return PrefabUtility.SaveAsPrefabAsset(container,path);
            }
            finally{UnityEngine.Object.DestroyImmediate(container);}
        }
        static Material Road(Material previous)
        {
            string path=Output+"/RoadSubtleWet.mat";Material material=AssetDatabase.LoadAssetAtPath<Material>(path);
            if(material!=null)return material;
            material=new Material(previous){name="RoadSubtleWet"};
            // Reduce the exaggerated repeating wet highlights seen in the user's screenshot.
            material.SetFloat("_Smoothness",.45f);
            if(material.HasProperty("_BumpScale"))material.SetFloat("_BumpScale",.22f);
            if(material.HasProperty("_SmoothnessRemapMax"))material.SetFloat("_SmoothnessRemapMax",.45f);
            AssetDatabase.CreateAsset(material,path);return material;
        }
        public static void ApplyTo(PassGame game)
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode)throw new InvalidOperationException("Stop Play before applying Scenic V3.");
            if(game==null)throw new InvalidOperationException("Open PassDemo first.");
            PassGraphicsUpgrade.ApplyTo(game);
            if(!AssetDatabase.IsValidFolder(Output))AssetDatabase.CreateFolder(Root+"/Generated","ScenicV3");
            // Validate/import before switching scene references. Old generated assets remain.
            GameObject broadleaf=Import("ForestSource","forest-generation-report.json","SM_BroadleafTree");
            GameObject pine=Import("ForestSource","forest-generation-report.json","SM_PineTree");
            GameObject bush=Import("ForestSource","forest-generation-report.json","SM_ForestBush");
            GameObject bike=Import("TravelSource","provenance.json","SM_TouringMotorbike");
            GameObject rider=Import("TravelSource","provenance.json","SM_RiderSeated");
            GameObject walker=Import("TravelSource","provenance.json","SM_ExplorerStanding");
            Undo.RecordObject(game,"Apply Scenic V3 art");
            game.BroadleafPrefab=broadleaf;game.PinePrefab=pine;game.BushPrefab=bush;
            game.BikeVisualPrefab=bike;game.RiderVisualPrefab=rider;game.WalkerVisualPrefab=walker;
            game.ScenicQuality=true;game.RoadMaterial=Road(game.RoadMaterial);
            game.RidingCameraDistance=5.5f;game.WalkingCameraDistance=4.5f;game.CameraFieldOfView=60;
            if(!Hdrp)
            {
                string skyPath=Output+"/OvercastSky.mat";Material sky=AssetDatabase.LoadAssetAtPath<Material>(skyPath);
                Shader shader=Shader.Find("Skybox/Procedural");
                if(sky==null&&shader!=null){sky=new Material(shader){name="OvercastSky"};sky.SetColor("_SkyTint",new Color(.52f,.60f,.63f));sky.SetColor("_GroundColor",new Color(.25f,.29f,.28f));sky.SetFloat("_AtmosphereThickness",1.35f);AssetDatabase.CreateAsset(sky,skyPath);}
                if(sky!=null)RenderSettings.skybox=sky;
                RenderSettings.ambientMode=AmbientMode.Trilight;RenderSettings.ambientSkyColor=new Color(.40f,.46f,.47f);RenderSettings.ambientEquatorColor=new Color(.28f,.32f,.29f);RenderSettings.ambientGroundColor=new Color(.15f,.17f,.15f);
                foreach(Light light in UnityEngine.Object.FindObjectsByType<Light>(FindObjectsSortMode.None))
                    if(light.type==LightType.Directional){Undo.RecordObject(light,"Overcast key light");light.intensity=.85f;light.color=new Color(.94f,.97f,1);RenderSettings.sun=light;break;}
            }
            EditorUtility.SetDirty(game);EditorSceneManager.MarkSceneDirty(game.gameObject.scene);AssetDatabase.SaveAssets();
        }
        [MenuItem("TravelVietnamese/Apply Scenic V3")]
        public static void Upgrade()
        {
            ApplyTo(UnityEngine.Object.FindFirstObjectByType<PassGame>());
            Debug.Log("SCENIC_V3_ASSIGNED: Ctrl+S then Play. Original art; inspect Unity image/performance before acceptance.");
        }
    }
}
