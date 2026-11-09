using UnityEngine;

namespace VietTrail.World
{
    /// <summary>Original illustrative northern route; metres are scene station units, not GIS.</summary>
    public static class TrailPath
    {
        public const float Length = 1600f;
        public const float RoadHalfWidth = 2.8f;
        public static readonly float[] BayStations = { 260f, 640f, 1100f };

        public static Vector3 Position(float meters)
        {
            float s = Mathf.Clamp(meters, 0f, Length);
            return new Vector3(22f * Mathf.Sin(s / 170f) + 9f * Mathf.Sin(s / 73f),
                3f + s * .014f + 2.4f * Mathf.Sin(s / 220f), s);
        }

        public static Vector3 Forward(float meters)
        {
            float s = Mathf.Clamp(meters, 0f, Length);
            return new Vector3(22f / 170f * Mathf.Cos(s / 170f) + 9f / 73f * Mathf.Cos(s / 73f),
                .014f + 2.4f / 220f * Mathf.Cos(s / 220f), 1f).normalized;
        }

        public static Vector3 Right(float meters)
        {
            return Vector3.Cross(Vector3.up, Forward(meters)).normalized;
        }

        public static Vector3 RoadPoint(float meters, float lane)
        {
            return Position(meters) + Right(meters) * lane;
        }

        public static float RightEdge(float meters)
        {
            float expansion = 0f;
            foreach (float station in BayStations)
            {
                float distance = Mathf.Abs(meters - station);
                // Full bay inside 12 m, smooth approach over the next 6 m.
                float weight = 1f - Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(12f, 18f, distance));
                expansion = Mathf.Max(expansion, weight);
            }
            return Mathf.Lerp(RoadHalfWidth, 7.5f, expansion);
        }

        public static bool IsBay(float meters)
        {
            foreach (float station in BayStations)
                if (Mathf.Abs(meters - station) <= 12f) return true;
            return false;
        }
    }
}
