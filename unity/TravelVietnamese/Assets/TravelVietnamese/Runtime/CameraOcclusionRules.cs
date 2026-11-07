using System;
namespace TravelVietnamese.Domain
{
    /// <summary>Camera geometry decisions, independent of Unity's physics implementation.</summary>
    public static class CameraOcclusionRules
    {
        public static bool ShouldIgnore(bool trigger, bool owned) { return trigger || owned; }
        public static float CollisionRadius(float nearClip, float verticalFovDegrees, float aspect)
        {
            float near = PassRules.Finite(nearClip) ? Math.Max(0.03f,nearClip) : 0.12f;
            float fov = PassRules.Finite(verticalFovDegrees) ? Math.Max(1,Math.Min(150,verticalFovDegrees)) : 69;
            float ratio = PassRules.Finite(aspect) ? Math.Max(0.1f,Math.Min(10,aspect)) : 1.78f;
            double halfHeight = near*Math.Tan(fov*Math.PI/360);
            // Enclose the near plane's farthest corner, measured from the camera centre.
            return Math.Max(0.28f,(float)Math.Sqrt(near*near+halfHeight*halfHeight*(1+ratio*ratio))+0.08f);
        }
        public static float AllowedDistance(float desired, float nearestHitDistance, float margin)
        {
            float length = PassRules.Finite(desired) ? Math.Max(0.05f,desired) : 5;
            if (!PassRules.Finite(nearestHitDistance)) return length;
            float clearance = PassRules.Finite(margin) ? Math.Max(0,margin) : 0.08f;
            // Do not impose the old 0.5m minimum beyond a wall closer than that minimum.
            return Math.Max(0,Math.Min(length,Math.Max(0,nearestHitDistance)-clearance));
        }
        public static float RecoverDistance(float current, float allowed, float deltaSeconds, float outwardSpeed, bool snap)
        {
            float target = PassRules.Finite(allowed) ? Math.Max(0,allowed) : 5;
            if (snap || !PassRules.Finite(current) || current<0 || target<current) return target;
            float dt = PassRules.Finite(deltaSeconds) ? Math.Max(0,Math.Min(0.1f,deltaSeconds)) : 0;
            float speed = PassRules.Finite(outwardSpeed) ? Math.Max(0,outwardSpeed) : 6;
            return Math.Min(target,current+dt*speed);
        }
    }
}
