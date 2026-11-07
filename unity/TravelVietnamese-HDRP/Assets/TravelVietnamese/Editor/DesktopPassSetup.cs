using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using TravelVietnamese.UnityPrototype;

namespace TravelVietnamese.Editor
{
    // Editor bootstrap source. Requires actual Unity 6 + resolved HDRP packages to run.
    public static class DesktopPassSetup
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
            Shader shader=Shader.Find("HDRP/Lit");
            if(shader==null) throw new InvalidOperationException("Resolve HDRP before generating materials.");
            Material material=new Material(shader){name=name};
            material.SetColor("_BaseColor",color);
            material.SetFloat("_Metallic",0);
            material.SetFloat("_Smoothness",smoothness);
            if(twoSided){material.SetFloat("_CullMode",0);material.SetFloat("_DoubleSidedEnable",1);material.EnableKeyword("_DOUBLESIDED_ON");material.doubleSidedGI=true;}
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
        static void DesktopPipeline()
        {
            if (!(GraphicsSettings.defaultRenderPipeline is HDRenderPipelineAsset))
                throw new InvalidOperationException("Configure HDRP using Window > Rendering > HDRP Wizard first; this desktop project is not a mobile build.");
            UnityEngine.Object[] settings=AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/ProjectSettings.asset");
            if(settings.Length>0)
            {
                SerializedObject serialized=new SerializedObject(settings[0]);
                SerializedProperty input=serialized.FindProperty("activeInputHandler");
                if(input!=null){input.intValue=0;serialized.ApplyModifiedPropertiesWithoutUndo();}
            }
        }
        [MenuItem("TravelVietnamese/Create Desktop Reference Pass")]
        public static void CreateDesktopPass()
        {
            if(File.Exists(ScenePath)) throw new InvalidOperationException("Scene exists; preserving user work: "+ScenePath);
            if(!Application.isBatchMode && !EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;
            Folder(Generated);Folder(Root+"/Scenes");
            DesktopPipeline();
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
            // Configure HDRP Fog/Volumetric Clouds in a global Volume after creation.
            RenderSettings.fog=true;RenderSettings.fogMode=FogMode.ExponentialSquared;
            RenderSettings.fogDensity=.003f;RenderSettings.fogColor=new Color(.48f,.55f,.57f);
            PassScenicUpgrade.ApplyTo(game);
            if(!EditorSceneManager.SaveScene(scene,ScenePath)) throw new IOException("Scene save failed.");
            EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene(ScenePath,true)};
            AssetDatabase.SaveAssets();
            Debug.Log("UNITY_SCENE_CREATED: source prototype, not visual/device acceptance.");
        }
    }
}
