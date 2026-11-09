using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;
using VietTrail.Presentation;
using VietTrail.Rendering;

namespace VietTrail.Editor
{
    public static class TrailProjectSetup
    {
        public const string EntryPath = "Assets/VietTrail/Scenes/Entry.unity";
        const string Theme = "Assets/VietTrail/Resources/Theme";
        const string RendererPath = Theme + "/PainterlyRenderer.asset";
        const string PipelinePath = Theme + "/PainterlyPipeline.asset";

        internal static void QueuePrepare()
        {
            EditorApplication.delayCall -= AutoPrepare;
            EditorApplication.delayCall += AutoPrepare;
        }

        static void AutoPrepare()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode) return;
            if (EditorApplication.isCompiling || EditorApplication.isUpdating)
            {
                QueuePrepare();
                return;
            }
            try { Prepare(); }
            catch (Exception error) { Debug.LogError("VietTrail setup needs attention: " + error); }
        }

        [MenuItem("VietTrail/Prepare project")]
        public static void Prepare()
        {
            Directory.CreateDirectory(Theme);
            // Safe Mode can finish compiling scripts before non-script assets have been imported.
            // Check the source separately, then force import it before requesting a Texture2D.
            string palettePath = Theme + "/PainterlyPalette.png";
            if (!File.Exists(palettePath))
                throw new FileNotFoundException("Palette source is absent. Update codex-work in this project root.", palettePath);
            AssetDatabase.ImportAsset(palettePath, ImportAssetOptions.ForceSynchronousImport | ImportAssetOptions.ForceUpdate);
            var palette = AssetDatabase.LoadAssetAtPath<Texture2D>(palettePath);
            if (palette == null)
            {
                var failedImporter = AssetImporter.GetAtPath(palettePath);
                var mainType = AssetDatabase.GetMainAssetTypeAtPath(palettePath);
                throw new InvalidOperationException("Palette import failed: importer=" +
                    (failedImporter == null ? "none" : failedImporter.GetType().FullName) +
                    ", mainAsset=" + (mainType == null ? "none" : mainType.FullName) +
                    ". Select the PNG and use Assets > Reimport; inspect earlier Console errors. Path: " + palettePath);
            }
            var importer = AssetImporter.GetAtPath(Theme + "/PainterlyPalette.png") as TextureImporter;
            if (importer != null && (importer.filterMode != FilterMode.Point || importer.mipmapEnabled || importer.textureCompression != TextureImporterCompression.Uncompressed || importer.wrapMode != TextureWrapMode.Clamp || importer.maxTextureSize != 512 || !importer.sRGBTexture || importer.alphaSource != TextureImporterAlphaSource.None))
            {
                ConfigurePalette(importer);
                importer.SaveAndReimport();
            }
            var renderer = AssetDatabase.LoadAssetAtPath<UniversalRendererData>(RendererPath);
            if (renderer == null)
            {
                renderer = ScriptableObject.CreateInstance<UniversalRendererData>();
                AssetDatabase.CreateAsset(renderer, RendererPath);
            }
            var pipeline = AssetDatabase.LoadAssetAtPath<UniversalRenderPipelineAsset>(PipelinePath);
            if (pipeline == null)
            {
                pipeline = UniversalRenderPipelineAsset.Create(renderer);
                pipeline.name = "VietTrail Painterly Mobile";
                pipeline.renderScale = 1f;
                pipeline.msaaSampleCount = 2;
                pipeline.shadowDistance = 65f;
                pipeline.shadowCascadeCount = 2;
                pipeline.supportsCameraDepthTexture = false;
                pipeline.supportsCameraOpaqueTexture = false;
                AssetDatabase.CreateAsset(pipeline, PipelinePath);
            }
            pipeline.supportsHDR = true;
            GraphicsSettings.defaultRenderPipeline = pipeline;
            QualitySettings.renderPipeline = pipeline;
            CreateMaterial("PainterlyWorld", "VietTrail/Painterly Lit", palette);
            CreateMaterial("PainterlySky", "VietTrail/Painterly Sky", null);
            string profilePath = Theme + "/PainterlyVolume.asset";
            if (AssetDatabase.LoadAssetAtPath<VolumeProfile>(profilePath) == null)
            {
                var profile = SharedPainterlyLook.CreateProfile();
                AssetDatabase.CreateAsset(profile, profilePath);
                foreach (var component in profile.components) AssetDatabase.AddObjectToAsset(component, profile);
            }
            PlayerSettings.companyName = "VietTrail";
            PlayerSettings.productName = "Phượt Xuyên Việt";
            PlayerSettings.bundleVersion = "0.1.0";
            PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
            PlayerSettings.colorSpace = ColorSpace.Linear;
            PlayerSettings.SetApplicationIdentifier(UnityEditor.Build.NamedBuildTarget.Android, "com.viettrail.journey");
            PlayerSettings.SetApplicationIdentifier(UnityEditor.Build.NamedBuildTarget.iOS, "com.viettrail.journey");
            PlayerSettings.Android.minSdkVersion = (AndroidSdkVersions)26;
            PlayerSettings.Android.targetSdkVersion = AndroidSdkVersions.AndroidApiLevelAuto;
            PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64;
            PlayerSettings.Android.forceInternetPermission = false;
            PlayerSettings.SetScriptingBackend(UnityEditor.Build.NamedBuildTarget.Android, ScriptingImplementation.IL2CPP);
            PlayerSettings.SetScriptingBackend(UnityEditor.Build.NamedBuildTarget.iOS, ScriptingImplementation.IL2CPP);
            var settings = AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/ProjectSettings.asset");
            if (settings.Length > 0)
            {
                var serialized = new SerializedObject(settings[0]);
                var input = serialized.FindProperty("activeInputHandler");
                if (input != null && input.intValue != 0) { input.intValue = 0; serialized.ApplyModifiedPropertiesWithoutUndo(); }
            }
            if (!File.Exists(EntryPath)) CreateEntry();
            var scenes = EditorBuildSettings.scenes.ToList();
            if (!scenes.Any(scene => scene.path == EntryPath)) scenes.Add(new EditorBuildSettingsScene(EntryPath, true));
            EditorBuildSettings.scenes = scenes.ToArray();
            AssetDatabase.SaveAssets();
        }

        static void CreateMaterial(string name, string shaderName, Texture2D palette)
        {
            string path = Theme + "/" + name + ".mat";
            // Preserve artist changes in materials already created in the Editor.
            if (AssetDatabase.LoadAssetAtPath<Material>(path) != null) return;
            Shader shader = Shader.Find(shaderName);
            if (shader == null) throw new InvalidOperationException("Missing shader " + shaderName);
            var material = new Material(shader) { name = name };
            if (palette != null) material.SetTexture("_Palette", palette);
            AssetDatabase.CreateAsset(material, path);
        }

        static void CreateEntry()
        {
            Directory.CreateDirectory("Assets/VietTrail/Scenes");
            Scene active = SceneManager.GetActiveScene();
            Scene entry = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            var root = new GameObject("VietTrail App");
            SceneManager.MoveGameObjectToScene(root, entry);
            root.AddComponent<TrailApp>();
            if (!EditorSceneManager.SaveScene(entry, EntryPath)) throw new IOException("Entry scene could not be saved.");
            EditorSceneManager.CloseScene(entry, true);
            if (active.IsValid()) SceneManager.SetActiveScene(active);
        }

        [MenuItem("VietTrail/Open journey")]
        public static void OpenJourney()
        {
            Prepare();
            if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) EditorSceneManager.OpenScene(EntryPath);
        }

        [MenuItem("VietTrail/Build Android APK")]
        public static void BuildAndroid()
        {
            Prepare();
            if (!BuildPipeline.IsBuildTargetSupported(BuildTargetGroup.Android, BuildTarget.Android))
                throw new InvalidOperationException("Install Unity Android Build Support, SDK/NDK and OpenJDK for this Editor first.");
            string output = Path.GetFullPath("artifacts/VietTrail-0.1.0.apk");
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            EditorUserBuildSettings.buildAppBundle = false;
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
                scenes = new[] { EntryPath }, locationPathName = output,
                target = BuildTarget.Android, options = BuildOptions.None
            });
            if (report.summary.result != BuildResult.Succeeded)
                throw new InvalidOperationException("Android build did not succeed: " + report.summary.result);
            Debug.Log("Built offline journey APK: " + output);
        }

        internal static void ConfigurePalette(TextureImporter importer)
        {
            importer.textureType = TextureImporterType.Default;
            importer.sRGBTexture = true;
            importer.alphaSource = TextureImporterAlphaSource.None;
            importer.filterMode = FilterMode.Point;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.maxTextureSize = 512;
            importer.npotScale = TextureImporterNPOTScale.None;
        }
    }

    public sealed class PainterlyPaletteImporter : AssetPostprocessor
    {
        static void OnPostprocessAllAssets(string[] imported, string[] deleted,
            string[] moved, string[] movedFrom, bool didDomainReload)
        {
            // Unlike InitializeOnLoad, this callback runs after the asset import pass.
            if (didDomainReload) TrailProjectSetup.QueuePrepare();
        }

        void OnPreprocessTexture()
        {
            if (assetPath == "Assets/VietTrail/Resources/Theme/PainterlyPalette.png")
                TrailProjectSetup.ConfigurePalette((TextureImporter)assetImporter);
        }
    }
}
