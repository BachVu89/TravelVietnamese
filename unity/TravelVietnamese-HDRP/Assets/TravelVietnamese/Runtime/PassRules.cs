using System;
using System.Collections.Generic;
namespace TravelVietnamese.Domain
{
    [Serializable]
    public sealed class JourneyState
    {
        public int Version = 1;
        public float BikeS = 5;
        public float BikeLane = 1.7f;
        public bool Riding = true;
        public List<string> Visited = new List<string>();
    }
    public static class PassRules
    {
        public const float Length = 750;
        public const float MaxSpeed = 18;
        public const float Acceleration = 5;
        public const float Brake = 12;
        public static readonly string[] StopIds = { "pass_demo:cloud_balcony", "pass_demo:valley_outlook" };
        public static readonly float[] StopDistances = { 230, 550 };
        public static bool Finite(float value) { return !float.IsNaN(value) && !float.IsInfinity(value); }
        public static bool IsStopZone(float distance, float lane)
        {
            if (!Finite(distance) || !Finite(lane) || lane < 4.4f || lane > 12) return false;
            foreach (float stop in StopDistances) if (Math.Abs(distance - stop) <= 17) return true;
            return false;
        }
        public static bool CanDismount(float speed, float distance, float lane)
        { return Finite(speed) && speed >= 0 && speed <= 0.5f && IsStopZone(distance, lane); }
        public static bool CanMount(float distanceToBike)
        { return Finite(distanceToBike) && distanceToBike >= 0 && distanceToBike <= 3; }
        public static bool TryVisit(JourneyState state, string id, bool riding, float proximity)
        {
            if (state == null || state.Visited == null || riding || !Finite(proximity) || proximity < 0 || proximity > 3.7f) return false;
            int index = Array.IndexOf(StopIds, id);
            if (index < 0 || state.Visited.Contains(id) || (index > 0 && !state.Visited.Contains(StopIds[index-1]))) return false;
            state.Visited.Add(id);
            return true;
        }
        public static float LatestPassedCheckpoint(float distance)
        {
            if (!Finite(distance)) return 0;
            float result = 0;
            foreach (float stop in StopDistances) if (distance >= stop) result = stop;
            return result;
        }
        public static JourneyState Normalize(JourneyState value)
        {
            JourneyState result = new JourneyState();
            if (value == null || value.Version != 1) return result;
            if (value.Visited != null)
            {
                foreach (string id in StopIds)
                {
                    if (!value.Visited.Contains(id)) break;
                    result.Visited.Add(id);
                }
            }
            if (Finite(value.BikeS) && value.BikeS >= 0 && value.BikeS <= Length && Finite(value.BikeLane) && value.BikeLane >= -3 && value.BikeLane <= 12)
            {
                result.BikeS = value.BikeS;
                result.BikeLane = value.BikeLane;
                if (result.BikeLane > 3.8f && !IsStopZone(result.BikeS,result.BikeLane)) result.BikeLane = 1.7f;
                result.Riding = value.Riding || !IsStopZone(result.BikeS,result.BikeLane);
            }
            return result;
        }
    }
}
