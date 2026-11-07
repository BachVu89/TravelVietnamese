using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using TravelVietnamese.UnityPrototype;

namespace TravelVietnamese.Editor
{
    // Explicit upgrade for scenes created before the original surface maps existed.
    public static class PassGraphicsUpgrade
    {
        const string Root="Assets/TravelVietnamese";
        const string Materials=Root+"/Generated/GraphicsV2";
        static Texture2D Map(string surface,string suffix,bool normal,bool linear)
        {
            string path=Root+"/Art/SurfaceMaps/"+surface+"_"+suffix+".png";
            TextureImporter importer=AssetImporter.GetAtPath(path) as TextureImporter;
            if(importer==null) throw new InvalidOperationException("Surface map missing/not imported: "+path);
            importer.textureType=normal?TextureImporterType.NormalMap:TextureImporterType.Default;
            importer.sRGBTexture=!linear&&!normal;importer.mipmapEnabled=true;
            importer.wrapMode=TextureWrapMode.Repeat;importer.anisoLevel=4;
            importer.SaveAndReimport();
            return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        }
        static Material Surface(string name,string surface,bool hdrp)
        {
            string path=Materials+"/"+name+".mat";
            Material existing=AssetDatabase.LoadAssetAtPath<Material>(path);
            if(existing!=null) return existing; // New version path preserves old artist materials.
            Shader shader=Shader.Find(hdrp?"HDRP/Lit":"Universal Render Pipeline/Lit");
            if(shader==null) throw new InvalidOperationException("Configure the project's render pipeline before applying graphics.");
            Material material=new Material(shader){name=name};
            material.SetColor("_BaseColor",Color.white);material.SetFloat("_Metallic",0);material.SetFloat("_Smoothness",1);
            material.SetTexture(hdrp?"_BaseColorMap":"_BaseMap",Map(surface,"BaseColor",false,false));
            Texture2D normal=Map(surface,"Normal",true,true),mask=Map(surface,"Mask",false,true);
            if(hdrp)
            {
                material.SetTexture("_NormalMap",normal);material.SetTexture("_MaskMap",mask);
                material.EnableKeyword("_NORMALMAP");material.EnableKeyword("_NORMALMAP_TANGENT_SPACE");material.EnableKeyword("_MASKMAP");
            }
            else
            {
                material.SetTexture("_BumpMap",normal);material.SetFloat("_BumpScale",0.45f);
                material.SetTexture("_MetallicGlossMap",mask);
                material.EnableKeyword("_NORMALMAP");material.EnableKeyword("_METALLICSPECGLOSSMAP");
            }
            AssetDatabase.CreateAsset(material,path);return material;
        }
        static GameObject CliffPrefab(GameObject source,Material rock)
        {
            if(source==null)return null;
            string path=Materials+"/CliffRockV2.prefab";
            GameObject existing=AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if(existing!=null)return existing;
            GameObject instance=(GameObject)PrefabUtility.InstantiatePrefab(source);
            try
            {
                foreach(Renderer renderer in instance.GetComponentsInChildren<Renderer>(true))
                {
                    Material[] slots=renderer.sharedMaterials;
                    if(slots.Length>0){slots[0]=rock;renderer.sharedMaterials=slots;}
                }
                return PrefabUtility.SaveAsPrefabAsset(instance,path);
            }
            finally {UnityEngine.Object.DestroyImmediate(instance);}
        }
        public static void ApplyTo(PassGame game)
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode) throw new InvalidOperationException("Stop Play before updating scene graphics.");
            if(game==null) throw new InvalidOperationException("Open the PassDemo scene containing PassGame first.");
            if(!AssetDatabase.IsValidFolder(Root+"/Generated")) AssetDatabase.CreateFolder(Root,"Generated");
            if(!AssetDatabase.IsValidFolder(Materials))AssetDatabase.CreateFolder(Root+"/Generated","GraphicsV2");
            bool hdrp=GraphicsSettings.defaultRenderPipeline!=null && GraphicsSettings.defaultRenderPipeline.GetType().Name.StartsWith("HD");
            Undo.RecordObject(game,"Apply original surface maps");
            game.RoadMaterial=Surface("RoadWetV2","Road",hdrp);
            game.RockMaterial=Surface("RockV2","Rock",hdrp);
            game.ShoulderMaterial=Surface("SoilV2","Soil",hdrp);
            if(game.RockPrefab!=null)game.RockPrefab=CliffPrefab(game.RockPrefab,game.RockMaterial);
            EditorUtility.SetDirty(game);EditorSceneManager.MarkSceneDirty(game.gameObject.scene);
            AssetDatabase.SaveAssets();
        }
        [MenuItem("TravelVietnamese/Update Scene Graphics")]
        public static void UpdateSceneGraphics()
        {
            PassGame game=UnityEngine.Object.FindFirstObjectByType<PassGame>();
            ApplyTo(game);
            Debug.Log("GRAPHICS_V2_ASSIGNED: save scene (Ctrl+S), then Play. Original procedural PBR maps, not scanned/photoreal assets.");
        }
    }
}
