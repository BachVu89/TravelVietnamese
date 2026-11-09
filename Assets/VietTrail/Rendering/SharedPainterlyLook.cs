using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace VietTrail.Rendering
{
    /// <summary>One look for both camera modes; no per-mode lighting or grading presets.</summary>
    public sealed class SharedPainterlyLook : MonoBehaviour
    {
        public static readonly Color Haze = new Color(.73f, .78f, .68f);
        VolumeProfile ownedProfile;
        public void Initialize(Camera camera, Material world)
        {
            RenderSettings.fogColor = Haze;
            // Custom painterly shader owns height/distance haze. Avoid applying built-in fog twice.
            RenderSettings.fog = false;
            world.SetColor("_HazeColor", Haze);
            var volume = gameObject.AddComponent<Volume>();
            volume.isGlobal = true;
            volume.priority = 10;
            var profile = Resources.Load<VolumeProfile>("Theme/PainterlyVolume");
            if (profile == null) profile = ownedProfile = CreateProfile();
            volume.sharedProfile = profile;
            ConfigureCamera(camera, gameObject.layer);
        }
        public static void ConfigureCamera(Camera camera, int volumeLayer)
        {
            if (camera == null) return;
            camera.allowHDR = true;
            var data = camera.GetUniversalAdditionalCameraData();
            data.renderPostProcessing = true;
            data.volumeLayerMask = 1 << volumeLayer;
        }
        public static VolumeProfile CreateProfile()
        {
            var profile = ScriptableObject.CreateInstance<VolumeProfile>();
            profile.name = "Shared Painterly Look";
            var bloom = profile.Add<Bloom>(true);
            bloom.intensity.Override(.12f); bloom.threshold.Override(1.15f);
            var grade = profile.Add<ColorAdjustments>(true);
            grade.contrast.Override(5); grade.saturation.Override(-4);
            var vignette = profile.Add<Vignette>(true);
            vignette.intensity.Override(.12f); vignette.smoothness.Override(.6f);
            var tone = profile.Add<Tonemapping>(true); tone.mode.Override(TonemappingMode.Neutral);
            return profile;
        }
        void OnDestroy()
        {
            if (ownedProfile == null) return;
            foreach (var component in ownedProfile.components) Destroy(component);
            Destroy(ownedProfile);
        }
    }
}
