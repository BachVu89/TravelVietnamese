using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using TravelVietnamese.UnityPrototype;

namespace TravelVietnamese.Editor
{
    // Editor bootstrap source. Requires actual Unity 6 + resolved URP packages to run.
    public static class PassProjectSetup
    {
        const string Root = "Assets/TravelVietnamese";
        const string ScenePath = Root + "/Scenes/PassDemo.unity";
        const string Generated = Root + "/Generated";
        static void Folder(string path)
        {
            if (AssetDatabase.IsValidFolder(path)) return;
            Folder(Path.GetDirectoryName(path).Replace('\\','/'));
            AssetDatabase.CreateFolder(Path.GetDirectoryName(path).Replace('\\','/'),Path.GetFileName(path));
        }
        static Material Surface(string name, Color color, float smoothness, bool twoSided=false)
        {
            string path=Generated+"/"+name+".mat";
            Material existing=AssetDatabase.LoadAssetAtPath<Material>(path);
            if(existing!=null) return existing; // Preserve artist edits.
            Shader shader=Shader.Find("Universal Render Pipeline/Lit");
            if(shader==null) throw new InvalidOperationException("Resolve URP before generating materials.");
            Material material=new Material(shader){name=name};
            material.SetColor("_BaseColor",color);
            material.SetFloat("_Metallic",0);
            material.SetFloat("_Smoothness",smoothness);
            if(twoSided){material.SetFloat("_Cull",0);material.doubleSidedGI=true;}
            AssetDatabase.CreateAsset(material,path);
            return material;
        }
        static GameObject Original(string name,Material[] palette)
        {
            string prefabPath=Generated+"/"+name+".prefab";
            GameObject existing=AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            if(existing!=null) return existing;
            string source=Root+"/Art/Original/"+name+".fbx";
            GameObject model=AssetDatabase.LoadAssetAtPath<GameObject>(source);
            if(model==null) throw new InvalidOperationException("Original FBX missing/not imported: "+source);
            GameObject instance=(GameObject)PrefabUtility.InstantiatePrefab(model);
            try
            {
                Renderer[] renderers=instance.GetComponentsInChildren<Renderer>(true);
                foreach(Renderer renderer in renderers)
                {
                    int slots=renderer.sharedMaterials.Length;
                    if(slots!=palette.Length) throw new InvalidOperationException("Material-slot mismatch for "+name+": "+slots);
                    renderer.sharedMaterials=palette;
                }
                foreach(Collider collider in instance.GetComponentsInChildren<Collider>(true)) UnityEngine.Object.DestroyImmediate(collider);
                return PrefabUtility.SaveAsPrefabAsset(instance,prefabPath);
            }
            finally { UnityEngine.Object.DestroyImmediate(instance); }
        }
        static void MobilePipeline()
        {
            string path=Generated+"/MobileURP.asset";
            UniversalRenderPipelineAsset pipeline=AssetDatabase.LoadAssetAtPath<UniversalRenderPipelineAsset>(path);
            if(pipeline==null)
            {
                UniversalRendererData renderer=ScriptableObject.CreateInstance<UniversalRendererData>();
                AssetDatabase.CreateAsset(renderer,Generated+"/MobileRenderer.asset");
                pipeline=UniversalRenderPipelineAsset.Create(renderer);
                pipeline.name="MobileURP";
                pipeline.msaaSampleCount=2;
                pipeline.shadowDistance=80;
                AssetDatabase.CreateAsset(pipeline,path);
            }
            GraphicsSettings.defaultRenderPipeline=pipeline;
            QualitySettings.renderPipeline=pipeline;
            PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.Android,"com.travelvietnamese.unityproof");
            PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.iOS,"com.travelvietnamese.unityproof");
            PlayerSettings.Android.minSdkVersion=AndroidSdkVersions.AndroidApiLevel26;
            PlayerSettings.Android.targetArchitectures=AndroidArchitecture.ARM64;
            PlayerSettings.Android.forceInternetPermission=false;
            PlayerSettings.defaultInterfaceOrientation=UIOrientation.LandscapeLeft;
            PlayerSettings.allowedAutorotateToPortrait=false;
            PlayerSettings.allowedAutorotateToPortraitUpsideDown=false;
            // Runtime uses the legacy Input API; do not depend on an unconfigured Input System.
            UnityEngine.Object[] settings=AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/ProjectSettings.asset");
            if(settings.Length>0)
            {
                SerializedObject serialized=new SerializedObject(settings[0]);
                SerializedProperty input=serialized.FindProperty("activeInputHandler");
                if(input!=null){input.intValue=0;serialized.ApplyModifiedPropertiesWithoutUndo();}
            }
        }
        [MenuItem("TravelVietnamese/Create Mobile Pass")]
        public static void CreateMobilePass()
        {
            if(File.Exists(ScenePath)) throw new InvalidOperationException("Scene exists; preserving user work: "+ScenePath);
            if(!Application.isBatchMode && !EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;
            Folder(Generated);Folder(Root+"/Scenes");
            MobilePipeline();
            var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
            Material road=Surface("RoadWet",new Color(.055f,.064f,.07f),.68f);
            Material soil=Surface("Shoulder",new Color(.19f,.17f,.13f),.12f);
            Material rock=Surface("DampStone",new Color(.24f,.26f,.22f),.18f);
            Material moss=Surface("Moss",new Color(.13f,.20f,.095f),.08f);
            Material foliage=Surface("Foliage",new Color(.085f,.24f,.065f),.18f,true);
            Material stem=Surface("PlantStem",new Color(.18f,.26f,.07f),.1f,true);
            Material bananaTrunk=Surface("BananaTrunk",new Color(.28f,.32f,.12f),.12f);
            Material bananaLeaf=Surface("BananaLeaf",new Color(.08f,.29f,.10f),.25f,true);
            Material bananaTip=Surface("BananaLeafTip",new Color(.16f,.35f,.10f),.2f,true);
            PassGame game=new GameObject("PassGame").AddComponent<PassGame>();
            game.RoadMaterial=road;game.ShoulderMaterial=soil;game.RockMaterial=rock;game.FoliageMaterial=foliage;
            game.RockPrefab=Original("SM_CliffRock",new[]{rock,moss});
            game.FernPrefab=Original("SM_Fern",new[]{stem,foliage});
            game.BananaPrefab=Original("SM_BananaClump",new[]{bananaTrunk,stem,bananaLeaf,bananaTip});
            Light sun=new GameObject("Overcast key light").AddComponent<Light>();
            sun.type=LightType.Directional;sun.intensity=1.05f;sun.shadows=LightShadows.Hard;
            sun.transform.rotation=Quaternion.Euler(42,-28,0);
            RenderSettings.ambientMode=AmbientMode.Flat;RenderSettings.ambientLight=new Color(.38f,.42f,.43f);
            RenderSettings.fog=true;RenderSettings.fogMode=FogMode.ExponentialSquared;
            RenderSettings.fogDensity=.003f;RenderSettings.fogColor=new Color(.48f,.55f,.57f);
            PassGraphicsUpgrade.ApplyTo(game);
            if(!EditorSceneManager.SaveScene(scene,ScenePath)) throw new IOException("Scene save failed.");
            EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene(ScenePath,true)};
            AssetDatabase.SaveAssets();
            Debug.Log("UNITY_SCENE_CREATED: source prototype, not visual/device acceptance.");
        }
        public static void BuildAndroid()
        {
            if(!File.Exists(ScenePath)) throw new InvalidOperationException("Generate PassDemo scene first.");
            if(!BuildPipeline.IsBuildTargetSupported(BuildTargetGroup.Android,BuildTarget.Android))
                throw new InvalidOperationException("Install licensed Editor Android Build Support + SDK/NDK/OpenJDK.");
            PlayerSettings.SetScriptingBackend(NamedBuildTarget.Android,ScriptingImplementation.IL2CPP);
            EditorUserBuildSettings.buildAppBundle=false;
            string output=Path.GetFullPath(Path.Combine(Application.dataPath,"../../../artifacts/unity-android/TravelVietnamese-Unity.apk"));
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            BuildReport report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{
                scenes=new[]{ScenePath},locationPathName=output,target=BuildTarget.Android,options=BuildOptions.Development});
            if(report.summary.result!=BuildResult.Succeeded)
                throw new InvalidOperationException("Android build failed: "+report.summary.result);
            Debug.Log("UNITY_ANDROID_BUILD_SUCCEEDED: "+output+"; install/offline/device tests still required.");
        }
    }
}
