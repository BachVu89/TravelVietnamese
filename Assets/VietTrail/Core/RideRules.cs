using System;
namespace VietTrail.Core
{
    public static class RideRules
    {
        public const float Length = 1600;
        public static readonly float[] Stops = {260,640,1100};
        public static readonly string[] Stamps = {"tea_hill","cloud_turn","village_gate"};
        public static bool Finite(float n){return !float.IsNaN(n)&&!float.IsInfinity(n);}
        public static bool InBay(float meters,float lane)
        {
            if(!Finite(meters)||!Finite(lane)||lane<3.6f||lane>6.5f)return false;
            foreach(float s in Stops)if(Math.Abs(s-meters)<=12)return true;
            return false;
        }
        public static bool CanDismount(float speed,float meters,float lane){return Finite(speed)&&speed>=0&&speed<=0.35f&&InBay(meters,lane);}
        public static bool CanMount(float distance){return Finite(distance)&&distance>=0&&distance<=2.5f;}
        public static bool Discover(JourneyState state,int stop,bool riding,float distance)
        {
            if(state==null||state.visited==null||riding||stop<0||stop>=Stops.Length||!Finite(distance)||distance<0||distance>3)return false;
            if(state.visited.Contains(Stamps[stop]))return false;
            for(int i=0;i<stop;i++)if(!state.visited.Contains(Stamps[i]))return false;
            state.visited.Add(Stamps[stop]);return true;
        }
        public static float Checkpoint(float meters)
        {float checkpoint=8;if(Finite(meters))foreach(float s in Stops)if(meters>=s)checkpoint=s;return checkpoint;}
        public static JourneyState Normalize(JourneyState input)
        {
            JourneyState output=new JourneyState();if(input==null||input.version!=1)return output;
            if(input.visited!=null)foreach(string id in Stamps){if(!input.visited.Contains(id))break;output.visited.Add(id);}
            if(Finite(input.meters)&&input.meters>=0&&input.meters<=Length)output.meters=input.meters;
            if(Finite(input.lane)&&input.lane>=-2.2f&&input.lane<=6.5f)output.lane=input.lane;
            if(output.lane>2.2f&&!InBay(output.meters,output.lane))output.lane=1.2f;
            if(input.options!=null)output.options=new JourneyOptions{music=Finite(input.options.music)?Math.Max(0,Math.Min(1,input.options.music)):0.65f,sfx=Finite(input.options.sfx)?Math.Max(0,Math.Min(1,input.options.sfx)):0.8f,quality=Math.Max(0,Math.Min(1,input.options.quality)),bikeColor=Math.Max(0,Math.Min(2,input.options.bikeColor))};
            return output;
        }
    }
}
