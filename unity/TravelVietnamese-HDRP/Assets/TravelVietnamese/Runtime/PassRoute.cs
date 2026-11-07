using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    public static class PassRoute
    {
        public static Vector3 Point(float s)
        {
            s = Mathf.Clamp(s,0,PassRules.Length);
            return new Vector3(26*Mathf.Sin(s/85)+10*Mathf.Sin(s/37),4+s*0.065f+3*Mathf.Sin(s/100),s);
        }
        public static Vector3 Forward(float s) { return (Point(Mathf.Min(s+0.2f,750))-Point(Mathf.Max(s-0.2f,0))).normalized; }
        public static Vector3 Right(float s) { return Vector3.Cross(Vector3.up,Forward(s)).normalized; }
        public static Vector3 At(float s,float lateral=0) { return Point(s)+Right(s)*lateral; }
        public static float Distance(Vector3 position)
        {
            float s = Mathf.Clamp(position.z,0,750);
            for (int i=0;i<5;i++) { Vector3 t=Forward(s); s=Mathf.Clamp(s+Vector3.Dot(position-Point(s),t)*Mathf.Abs(t.z),0,750); }
            return s;
        }
        public static float Lane(Vector3 position) { float s=Distance(position); return Vector3.Dot(position-Point(s),Right(s)); }
        public static float Edge(float s)
        { foreach(float stop in PassRules.StopDistances) if(Mathf.Abs(s-stop)<21) return 13; return 4.25f; }
    }
}
