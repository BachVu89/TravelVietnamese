using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace TravelVietnamese.Editor
{
    /// <summary>Catalog-driven static review; never assigns a gameplay avatar or vehicle.</summary>
    public static class PassMeshyAssetLibrary
    {
        const string CatalogPath="Assets/TravelVietnamese/Art/Imported/Meshy/catalog.json";
        [Serializable] public sealed class AssetEntry
        {
            public string id,label,source_folder,output_folder,intended_use;
            public bool available,has_lod1,apply_in_demo;
            public float review_yaw_degrees;
        }
        [Serializable] sealed class Catalog {public AssetEntry[] assets;}
        public sealed class PreparedAsset {public AssetEntry Entry;public GameObject Prefab;}
        static string AssetFolder(string path)
        {
            if(string.IsNullOrEmpty(path)||!path.StartsWith("Assets/TravelVietnamese/",StringComparison.Ordinal)||path.Contains("..")||path.Contains("\\"))
                throw new InvalidOperationException("Invalid catalog asset folder: "+path);
            return path.TrimEnd('/');
        }
        static void EnsureFolder(string path)
        {
            string[] parts=AssetFolder(path).Split('/');string parent=parts[0];
            for(int i=1;i<parts.Length;i++){string next=parent+"/"+parts[i];if(!AssetDatabase.IsValidFolder(next))AssetDatabase.CreateFolder(parent,parts[i]);parent=next;}
        }
        static AssetEntry[] ReadCatalog()
        {
            TextAsset text=AssetDatabase.LoadAssetAtPath<TextAsset>(CatalogPath);
            if(text==null)throw new InvalidOperationException("Meshy catalog missing: "+CatalogPath);
            Catalog catalog=JsonUtility.FromJson<Catalog>(text.text);
            if(catalog==null||catalog.assets==null)throw new InvalidOperationException("Invalid Meshy catalog.");
            var ids=new HashSet<string>();
            foreach(AssetEntry entry in catalog.assets)
                if(entry==null||string.IsNullOrEmpty(entry.id)||!ids.Add(entry.id))throw new InvalidOperationException("Missing or duplicate Meshy catalog ID.");
            return catalog.assets;
        }
        static GameObject PrepareEntry(AssetEntry entry)
        {
            string source=AssetFolder(entry.source_folder),output=AssetFolder(entry.output_folder);EnsureFolder(output);
            if(!entry.has_lod1)return PassMeshyUpgrade.PrepareAsset(source,output);
            string path=output+"/Preview.prefab";GameObject existing=AssetDatabase.LoadAssetAtPath<GameObject>(path);if(existing!=null)return existing;
            EnsureFolder(output+"/LOD0");EnsureFolder(output+"/LOD1");
            GameObject high=PassMeshyUpgrade.PrepareAsset(source,output+"/LOD0","unity-import.json");
            GameObject low=PassMeshyUpgrade.PrepareAsset(source,output+"/LOD1","unity-import-lod1.json");
            if(high==null||low==null)throw new InvalidOperationException("Missing prepared LOD for "+entry.id);
            GameObject wrapper=new GameObject("MeshyReview_"+entry.id);
            try
            {
                GameObject a=(GameObject)PrefabUtility.InstantiatePrefab(high),b=(GameObject)PrefabUtility.InstantiatePrefab(low);
                a.transform.SetParent(wrapper.transform,false);b.transform.SetParent(wrapper.transform,false);a.name="LOD0";b.name="LOD1";
                Renderer[] ra=a.GetComponentsInChildren<Renderer>(true),rb=b.GetComponentsInChildren<Renderer>(true);
                if(ra.Length==0||rb.Length==0)throw new InvalidOperationException("LOD renderer missing: "+entry.id);
                LODGroup group=wrapper.AddComponent<LODGroup>();group.fadeMode=LODFadeMode.None;group.SetLODs(new[]{new LOD(0.5f,ra),new LOD(0.02f,rb)});group.RecalculateBounds();
                GameObject prefab=PrefabUtility.SaveAsPrefabAsset(wrapper,path);if(prefab==null)throw new InvalidOperationException("Cannot save "+path);return prefab;
            }
            finally{UnityEngine.Object.DestroyImmediate(wrapper);}
        }
        public static List<PreparedAsset> PrepareAll()
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode)throw new InvalidOperationException("Stop Play before preparing Meshy assets.");
            var result=new List<PreparedAsset>();
            foreach(AssetEntry entry in ReadCatalog())
            {
                if(!entry.available){Debug.Log("SKIP unavailable Meshy asset: "+entry.id);continue;}
                GameObject prefab=PrepareEntry(entry);result.Add(new PreparedAsset{Entry=entry,Prefab=prefab});
                Debug.Log("Prepared static review asset: "+entry.label+" | source: "+entry.source_folder+" | intended use: "+entry.intended_use+". Not assigned to gameplay.",prefab);
            }
            return result;
        }
        static Bounds RendererBounds(GameObject model)
        {
            Renderer[] renderers=model.GetComponentsInChildren<Renderer>(true);if(renderers.Length==0)throw new InvalidOperationException("Review asset has no renderer: "+model.name);
            Bounds bounds=renderers[0].bounds;foreach(Renderer renderer in renderers)bounds.Encapsulate(renderer.bounds);
            Vector3 size=bounds.size;if(float.IsNaN(size.sqrMagnitude)||float.IsInfinity(size.sqrMagnitude)||size.sqrMagnitude<0.000001f)throw new InvalidOperationException("Invalid review bounds: "+model.name);return bounds;
        }
        [MenuItem("TravelVietnamese/Select Prepared Meshy Prefabs")]
        public static void SelectPreparedPrefabs()
        {
            try{List<PreparedAsset> items=PrepareAll();var selection=new UnityEngine.Object[items.Count];for(int i=0;i<items.Count;i++)selection[i]=items[i].Prefab;Selection.objects=selection;if(selection.Length>0)EditorGUIUtility.PingObject(selection[0]);}
            catch(Exception ex){Debug.LogException(ex);EditorUtility.DisplayDialog("Meshy library",ex.Message,"Close");}
        }
        public static void ReviewAll()
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode){EditorUtility.DisplayDialog("Meshy review","Stop Play before opening the review scene.","Close");return;}
            if(!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())return;
            try
            {
                EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects,NewSceneMode.Single);
                List<PreparedAsset> assets=PrepareAll();if(assets.Count==0)throw new InvalidOperationException("No catalog entries are currently available.");
                float x=0,z=0,rowDepth=0;int column=0;Bounds gallery=new Bounds();bool hasBounds=false;
                foreach(PreparedAsset asset in assets)
                {
                    GameObject model=(GameObject)PrefabUtility.InstantiatePrefab(asset.Prefab);model.name="REVIEW ONLY — "+asset.Entry.label;
                    model.transform.rotation=Quaternion.Euler(0,asset.Entry.review_yaw_degrees,0);
                    foreach(LODGroup group in model.GetComponentsInChildren<LODGroup>(true))group.ForceLOD(0); // Instance only: no prefab mutation.
                    Bounds bounds=RendererBounds(model);float gap=Mathf.Max(0.7f,Mathf.Max(bounds.size.x,bounds.size.z)*0.12f);
                    model.transform.position+=new Vector3(x-bounds.min.x,-bounds.min.y,z-bounds.min.z);
                    bounds=RendererBounds(model);if(!hasBounds){gallery=bounds;hasBounds=true;}else gallery.Encapsulate(bounds);
                    GameObject label=new GameObject("Label — "+asset.Entry.id);label.transform.position=new Vector3(bounds.center.x,bounds.max.y+0.25f,bounds.min.z-0.1f);
                    TextMesh text=label.AddComponent<TextMesh>();text.text=asset.Entry.label+"\n"+asset.Entry.intended_use;text.anchor=TextAnchor.LowerCenter;text.alignment=TextAlignment.Center;text.fontSize=32;text.characterSize=Mathf.Clamp(bounds.size.y*0.035f,0.045f,0.3f);
                    Font font=Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");if(font!=null){text.font=font;label.GetComponent<MeshRenderer>().sharedMaterial=font.material;}
                    x+=bounds.size.x+gap;rowDepth=Mathf.Max(rowDepth,bounds.size.z+gap);column++;
                    if(column==3){column=0;x=0;z+=rowDepth;rowDepth=0;}
                }
                GameObject floor=GameObject.CreatePrimitive(PrimitiveType.Plane);floor.name="Static asset review floor";floor.transform.position=new Vector3(gallery.center.x,-0.02f,gallery.center.z);floor.transform.localScale=new Vector3(Mathf.Max(1,(gallery.size.x+3)/10),1,Mathf.Max(1,(gallery.size.z+3)/10));
                bool hdrp=GraphicsSettings.defaultRenderPipeline!=null&&GraphicsSettings.defaultRenderPipeline.GetType().Name.StartsWith("HD");Shader shader=Shader.Find(hdrp?"HDRP/Lit":"Universal Render Pipeline/Lit");
                if(shader!=null){Material material=new Material(shader){name="Transient gallery floor"};material.SetColor("_BaseColor",new Color(0.22f,0.26f,0.25f));material.SetFloat("_Smoothness",0.2f);floor.GetComponent<Renderer>().sharedMaterial=material;}
                Camera camera=Camera.main;float extent=Mathf.Max(gallery.size.x,Mathf.Max(gallery.size.y*1.5f,gallery.size.z));Vector3 target=gallery.center+Vector3.up*gallery.size.y*0.1f;
                if(camera!=null){camera.fieldOfView=48;camera.nearClipPlane=0.05f;camera.farClipPlane=Mathf.Max(100,extent*10);camera.transform.position=target+new Vector3(0,extent*0.28f,-extent*1.7f-2);camera.transform.LookAt(target);camera.clearFlags=CameraClearFlags.SolidColor;camera.backgroundColor=new Color(0.32f,0.38f,0.39f);}
                Light light=UnityEngine.Object.FindFirstObjectByType<Light>();if(light!=null){light.transform.rotation=Quaternion.Euler(45,-25,0);light.intensity=hdrp?3:1.4f;light.shadows=LightShadows.Soft;}
                RenderSettings.ambientMode=AmbientMode.Flat;RenderSettings.ambientLight=new Color(0.6f,0.65f,0.66f);RenderSettings.fog=false;
                if(SceneView.lastActiveSceneView!=null)SceneView.lastActiveSceneView.Frame(gallery,false);
                EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
                Selection.activeObject=assets[0].Prefab;EditorGUIUtility.PingObject(assets[0].Prefab);
                Debug.Log("Opened UNSAVED Meshy gallery. Review instances force LOD0: this is NOT a performance benchmark or an animation/playability claim. Select prefab assets in Project using the Console context or Select Prepared Meshy Prefabs menu. PassDemo and gameplay assignments were not changed.");
            }
            catch(Exception ex){Debug.LogException(ex);EditorUtility.DisplayDialog("Meshy gallery",ex.Message,"Close");}
        }
    }
}
