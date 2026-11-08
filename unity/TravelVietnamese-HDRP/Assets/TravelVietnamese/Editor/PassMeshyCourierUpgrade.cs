using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace TravelVietnamese.Editor
{
    /// <summary>Static, unrigged courier asset review only. Does not replace gameplay avatars.</summary>
    public static class PassMeshyCourierUpgrade
    {
        const string CourierSource="Assets/TravelVietnamese/Art/Imported/Meshy/Courier";
        const string CourierOutput="Assets/TravelVietnamese/Generated/MeshyCourier";
        const string MilestoneSource="Assets/TravelVietnamese/Art/Imported/Meshy/Milestone";
        const string MilestoneOutput="Assets/TravelVietnamese/Generated/MeshyMilestone";

        static void EnsureFolder(string path)
        {
            string[] parts=path.Split('/');string parent=parts[0];
            for(int i=1;i<parts.Length;i++)
            {
                string next=parent+"/"+parts[i];
                if(!AssetDatabase.IsValidFolder(next))AssetDatabase.CreateFolder(parent,parts[i]);
                parent=next;
            }
        }

        public static GameObject PrepareCourier()
        {
            if(EditorApplication.isPlayingOrWillChangePlaymode)throw new InvalidOperationException("Stop Play before preparing Meshy previews.");
            EnsureFolder(CourierOutput);
            string path=CourierOutput+"/CourierPreview.prefab";
            GameObject existing=AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if(existing!=null)return existing;
            EnsureFolder(CourierOutput+"/LOD0");EnsureFolder(CourierOutput+"/LOD1");
            GameObject high=PassMeshyUpgrade.PrepareAsset(CourierSource,CourierOutput+"/LOD0","unity-import.json");
            GameObject low=PassMeshyUpgrade.PrepareAsset(CourierSource,CourierOutput+"/LOD1","unity-import-lod1.json");
            if(high==null || low==null)throw new InvalidOperationException("Prepare both courier LOD prefabs before creating a review asset.");
            GameObject root=new GameObject("MeshyCourier_StaticUnrigged_Apose_Review");
            try
            {
                GameObject lod0=(GameObject)PrefabUtility.InstantiatePrefab(high);
                GameObject lod1=(GameObject)PrefabUtility.InstantiatePrefab(low);
                lod0.transform.SetParent(root.transform,false);lod1.transform.SetParent(root.transform,false);
                lod0.name="LOD0_Static";lod1.name="LOD1_Static";
                // Normalised wrapper prefabs retain their import-axis conversions and mesh pivots.
                // No bone, rig, skinning, pose conversion, collider or animation is fabricated.
                Renderer[] renderers0=lod0.GetComponentsInChildren<Renderer>(true);
                Renderer[] renderers1=lod1.GetComponentsInChildren<Renderer>(true);
                if(renderers0.Length==0 || renderers1.Length==0)throw new InvalidOperationException("Courier LOD has no renderer.");
                LODGroup group=root.AddComponent<LODGroup>();group.fadeMode=LODFadeMode.None;
                group.SetLODs(new[]{new LOD(0.55f,renderers0),new LOD(0.15f,renderers1)});
                group.RecalculateBounds();
                GameObject prefab=PrefabUtility.SaveAsPrefabAsset(root,path);
                if(prefab==null)throw new InvalidOperationException("Cannot save combined courier review prefab.");
                AssetDatabase.SaveAssets();return prefab;
            }
            finally{UnityEngine.Object.DestroyImmediate(root);}
        }

        [MenuItem("TravelVietnamese/Review Meshy Assets")]
        public static void ReviewAssets()
        {
            PassMeshyAssetLibrary.ReviewAll();
        }
    }
}
