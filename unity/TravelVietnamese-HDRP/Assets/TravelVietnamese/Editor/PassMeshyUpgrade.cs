using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using TravelVietnamese.UnityPrototype;

namespace TravelVietnamese.Editor
{
    /// <summary>Explicitly binds actual user-supplied Meshy PBR files; no download or generation.</summary>
    public static class PassMeshyUpgrade
    {
        const string Source="Assets/TravelVietnamese/Art/Imported/Meshy/Milestone";
        const string Output="Assets/TravelVietnamese/Generated/MeshyMilestone";
        [Serializable] sealed class Spec
        {
            public string fbx,base_color,normal,mask;
            public string prefab_name="Milestone";
            public float target_height_m=1.4f,yaw_offset_degrees=-90;
            public bool flip_normal_green;
        }
        static Texture2D Texture(string sourceFolder,string filename,bool normal,bool linear,bool flipGreen=false)
        {
            if(string.IsNullOrEmpty(filename)||filename.Contains("/")||filename.Contains("\\")||filename.Contains(".."))
                throw new InvalidOperationException("Invalid Meshy texture filename.");
            string path=sourceFolder+"/"+filename;
            TextureImporter importer=AssetImporter.GetAtPath(path) as TextureImporter;
            if(importer==null)throw new InvalidOperationException("Meshy texture missing: "+path);
            importer.textureType=normal?TextureImporterType.NormalMap:TextureImporterType.Default;
            importer.sRGBTexture=!normal&&!linear;importer.mipmapEnabled=true;
            importer.wrapMode=TextureWrapMode.Clamp;importer.anisoLevel=4;importer.maxTextureSize=2048;
            importer.textureCompression=TextureImporterCompression.Compressed;
            if(normal)importer.flipGreenChannel=flipGreen;
            importer.SaveAndReimport();return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        }
        static Material MaterialFor(Spec spec,string sourceFolder,string outputFolder)
        {
            string path=outputFolder+"/PBR.mat";
            Material existing=AssetDatabase.LoadAssetAtPath<Material>(path);if(existing!=null)return existing;
            bool hdrp=GraphicsSettings.defaultRenderPipeline!=null&&GraphicsSettings.defaultRenderPipeline.GetType().Name.StartsWith("HD");
            Shader shader=Shader.Find(hdrp?"HDRP/Lit":"Universal Render Pipeline/Lit");
            if(shader==null)throw new InvalidOperationException("Configure the project's render pipeline first.");
            Texture2D color=Texture(sourceFolder,spec.base_color,false,false),normal=Texture(sourceFolder,spec.normal,true,true,spec.flip_normal_green),mask=Texture(sourceFolder,spec.mask,false,true);
            Material material=new Material(shader){name=spec.prefab_name+"PBR",enableInstancing=true};
            material.SetColor("_BaseColor",Color.white);material.SetFloat("_Smoothness",1);
            material.SetTexture(hdrp?"_BaseColorMap":"_BaseMap",color);
            if(hdrp)
            {
                material.SetTexture("_NormalMap",normal);material.SetTexture("_MaskMap",mask);
                material.EnableKeyword("_NORMALMAP");material.EnableKeyword("_NORMALMAP_TANGENT_SPACE");material.EnableKeyword("_MASKMAP");
            }
            else
            {
                material.SetTexture("_BumpMap",normal);material.SetFloat("_BumpScale",1);
                material.SetTexture("_MetallicGlossMap",mask);
                material.EnableKeyword("_NORMALMAP");material.EnableKeyword("_METALLICSPECGLOSSMAP");
            }
            AssetDatabase.CreateAsset(material,path);return material;
        }
        static Bounds BoundsOf(GameObject root)
        {
            Renderer[] renderers=root.GetComponentsInChildren<Renderer>(true);
            if(renderers.Length==0)throw new InvalidOperationException("Meshy FBX has no rendered mesh.");
            Bounds bounds=renderers[0].bounds;foreach(Renderer renderer in renderers)bounds.Encapsulate(renderer.bounds);
            if(!PassRulesFinite(bounds.size.y)||bounds.size.y<0.0001f)throw new InvalidOperationException("Invalid imported mesh height.");
            return bounds;
        }
        static bool PassRulesFinite(float value){return !float.IsNaN(value)&&!float.IsInfinity(value);}
        static GameObject Prefab(Spec spec,Material material,string sourceFolder,string outputFolder)
        {
            string path=outputFolder+"/"+spec.prefab_name+".prefab";
            GameObject existing=AssetDatabase.LoadAssetAtPath<GameObject>(path);if(existing!=null)return existing;
            if(string.IsNullOrEmpty(spec.fbx)||spec.fbx.Contains("/")||spec.fbx.Contains("\\")||spec.fbx.Contains(".."))throw new InvalidOperationException("Invalid FBX filename.");
            string source=sourceFolder+"/"+spec.fbx;
            ModelImporter importer=AssetImporter.GetAtPath(source) as ModelImporter;
            if(importer==null)throw new InvalidOperationException("Meshy FBX not imported: "+source);
            // Embedded .fbm references are absent in this export. Bind supplied PNGs explicitly.
            importer.materialImportMode=ModelImporterMaterialImportMode.None;
            importer.importAnimation=false;importer.SaveAndReimport();
            GameObject model=AssetDatabase.LoadAssetAtPath<GameObject>(source);
            if(model==null)throw new InvalidOperationException("Meshy model unavailable.");
            GameObject wrapper=new GameObject(spec.prefab_name+"_Visual");
            try
            {
                GameObject child=(GameObject)PrefabUtility.InstantiatePrefab(model);
                child.transform.SetParent(wrapper.transform,false);
                foreach(Collider collider in child.GetComponentsInChildren<Collider>(true))UnityEngine.Object.DestroyImmediate(collider);
                foreach(Renderer renderer in child.GetComponentsInChildren<Renderer>(true))
                {
                    Material[] slots=new Material[Mathf.Max(1,renderer.sharedMaterials.Length)];
                    for(int i=0;i<slots.Length;i++)slots[i]=material;renderer.sharedMaterials=slots;
                }
                if(!PassRulesFinite(spec.target_height_m)||spec.target_height_m<0.1f||spec.target_height_m>5)
                    throw new InvalidOperationException("Invalid Meshy display height.");
                Bounds bounds=BoundsOf(child);child.transform.localScale*=spec.target_height_m/bounds.size.y;
                bounds=BoundsOf(child);child.transform.localPosition-=new Vector3(bounds.center.x,bounds.min.y,bounds.center.z);
                return PrefabUtility.SaveAsPrefabAsset(wrapper,path);
            }
            finally{UnityEngine.Object.DestroyImmediate(wrapper);}
        }
        static void Folder(string path)
        {
            if(AssetDatabase.IsValidFolder(path))return;
            int slash=path.LastIndexOf('/');if(slash<0)throw new InvalidOperationException("Invalid asset folder.");
            string parent=path.Substring(0,slash);Folder(parent);AssetDatabase.CreateFolder(parent,path.Substring(slash+1));
        }
        public static GameObject PrepareAsset(string sourceFolder,string outputFolder,string configFile="unity-import.json")
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode)throw new InvalidOperationException("Stop Play before importing Meshy assets.");
            TextAsset text=AssetDatabase.LoadAssetAtPath<TextAsset>(sourceFolder+"/"+configFile);
            if(text==null)throw new InvalidOperationException("Meshy import specification missing: "+sourceFolder);
            Spec spec=JsonUtility.FromJson<Spec>(text.text);
            if(string.IsNullOrEmpty(spec.prefab_name)||spec.prefab_name.Contains("/")||spec.prefab_name.Contains("\\")||spec.prefab_name.Contains(".."))throw new InvalidOperationException("Invalid prefab name.");
            Folder(outputFolder);
            return Prefab(spec,MaterialFor(spec,sourceFolder,outputFolder),sourceFolder,outputFolder);
        }
        public static void ApplyTo(PassGame game)
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode)throw new InvalidOperationException("Stop Play before applying Meshy assets.");
            if(game==null)throw new InvalidOperationException("Open PassDemo first.");
            TextAsset text=AssetDatabase.LoadAssetAtPath<TextAsset>(Source+"/unity-import.json");
            if(text==null)throw new InvalidOperationException("Milestone import specification missing.");
            Spec spec=JsonUtility.FromJson<Spec>(text.text);
            GameObject prefab=PrepareAsset(Source,Output);
            var prepared=PassMeshyAssetLibrary.PrepareAll();
            Undo.RecordObject(game,"Apply supplied Meshy milestone");
            game.MilestoneVisualPrefab=prefab;game.MilestoneYawOffset=spec.yaw_offset_degrees;
            foreach(var asset in prepared)
                if(asset.Entry.id=="fern_terraces")
                {
                    if(asset.Entry.apply_in_demo)game.MeshyFernPatchPrefab=asset.Prefab;
                    else if(game.MeshyFernPatchPrefab!=null && AssetDatabase.GetAssetPath(game.MeshyFernPatchPrefab).StartsWith(asset.Entry.output_folder+"/",StringComparison.Ordinal))
                        game.MeshyFernPatchPrefab=null; // Clear a declined catalog version, not an artist's unrelated prefab.
                }
            EditorUtility.SetDirty(game);EditorSceneManager.MarkSceneDirty(game.gameObject.scene);AssetDatabase.SaveAssets();
        }
        [MenuItem("TravelVietnamese/Apply Meshy Assets")]
        public static void Upgrade()
        {
            ApplyTo(UnityEngine.Object.FindFirstObjectByType<PassGame>());
            Debug.Log("MESHY_MILESTONE_ASSIGNED: Ctrl+S then Play. Only catalog-approved demo decorations are assigned; other models remain static assets, without rig or seated animation.");
        }
    }
}
