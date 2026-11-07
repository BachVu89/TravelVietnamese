using System;
using System.Collections.Generic;
using TravelVietnamese.Domain;
class DomainHarness
{
    static int count;
    static void Check(bool condition,string name) { count++; if(!condition)throw new Exception("FAIL: "+name); }
    static void Main()
    {
        foreach(float invalid in new[]{float.NaN,float.PositiveInfinity,float.NegativeInfinity}) {
            Check(!PassRules.CanDismount(invalid,230,8),"invalid speed");
            Check(!PassRules.CanDismount(0,invalid,8),"invalid position");
            Check(!PassRules.CanMount(invalid),"invalid mount distance");
        }
        Check(PassRules.CanDismount(.5f,213,4.4f),"inclusive minimum stop boundary");
        Check(PassRules.CanDismount(0,567,12),"inclusive maximum stop boundary");
        foreach(float speed in new[]{-.01f,.501f,18f}) Check(!PassRules.CanDismount(speed,230,8),"moving/negative dismount blocked");
        Check(!PassRules.CanDismount(0,212.99f,8),"before layby");
        Check(!PassRules.CanDismount(0,247.01f,8),"after layby");
        Check(!PassRules.CanDismount(0,230,4.39f),"road lane not layby");
        Check(!PassRules.CanDismount(0,230,12.01f),"outside safe lane");
        Check(PassRules.CanMount(3) && PassRules.CanMount(0),"mount endpoints");
        Check(!PassRules.CanMount(3.001f) && !PassRules.CanMount(-.01f),"mount proximity guard");
        float[] positions={0,220,229.99f,230,540,549.99f,550,750};
        float[] expected={0,0,0,230,230,230,550,550};
        for(int i=0;i<positions.Length;i++)Check(PassRules.LatestPassedCheckpoint(positions[i])==expected[i],"checkpoint never jumps ahead "+positions[i]);
        var state=new JourneyState(); string a=PassRules.StopIds[0],b=PassRules.StopIds[1];
        Check(!PassRules.TryVisit(state,b,false,0),"second POI requires first");
        Check(!PassRules.TryVisit(state,a,true,0),"riding cannot stamp");
        foreach(float distance in new[]{-.1f,3.701f,float.NaN,float.PositiveInfinity})Check(!PassRules.TryVisit(state,a,false,distance),"invalid POI distance");
        Check(!PassRules.TryVisit(state,"unknown",false,0),"unknown POI");
        Check(PassRules.TryVisit(state,a,false,3.7f),"first POI boundary");
        Check(!PassRules.TryVisit(state,a,false,0),"duplicate stamp");
        Check(PassRules.TryVisit(state,b,false,0),"second stamp after first");
        Check(state.Visited.Count==2,"no failed calls mutate stamps");
        var saved=PassRules.Normalize(new JourneyState{BikeS=550,BikeLane=8,Riding=false,Visited=new List<string>{a,b,b,"bad"}});
        Check(saved.BikeS==550 && saved.BikeLane==8 && !saved.Riding && saved.Visited.Count==2,"valid walking save and canonical stamps");
        saved.Visited.Clear(); Check(state.Visited.Count==2,"normalized collection independent");
        var orphan=PassRules.Normalize(new JourneyState{Visited=new List<string>{b}});
        Check(orphan.Visited.Count==0,"orphan second stamp removed");
        foreach(float invalid in new[]{float.NaN,float.PositiveInfinity,-1f,750.01f}) {
            var n=PassRules.Normalize(new JourneyState{BikeS=invalid,BikeLane=8,Riding=false,Visited=new List<string>{a,b}});
            Check(n.BikeS==5 && n.BikeLane==1.7f && n.Riding && n.Visited.Count==2,"invalid pose keeps valid stamps");
        }
        foreach(float lane in new[]{float.NaN,float.NegativeInfinity,-3.01f,12.01f}) {
            var n=PassRules.Normalize(new JourneyState{BikeS=230,BikeLane=lane,Riding=false,Visited=new List<string>{a}});
            Check(n.BikeS==5 && n.Riding && n.Visited.Count==1,"invalid lane defaults pose preserving stamp");
        }
        var original=new JourneyState{BikeS=230,BikeLane=8,Riding=false,Visited=new List<string>{a,a,b,"unknown"}};
        var once=PassRules.Normalize(original); var twice=PassRules.Normalize(once);
        Check(once.BikeS==twice.BikeS && once.BikeLane==twice.BikeLane && once.Riding==twice.Riding && string.Join(",",once.Visited)==string.Join(",",twice.Visited),"normalization idempotent");
        Check(original.Visited.Count==4,"normalization does not mutate source");
        Check(!PassRules.TryVisit(null,a,false,0),"null state visit rejected");
        Check(!PassRules.TryVisit(new JourneyState{Visited=null},a,false,0),"null visited visit rejected");
        var outside=PassRules.Normalize(new JourneyState{BikeS=470,BikeLane=8,Riding=false});
        Check(outside.BikeLane==1.7f && outside.Riding,"malformed off-layby walking save corrected");
        Check(PassRules.Normalize(null).BikeS==5,"missing save defaults");
        Check(PassRules.Normalize(new JourneyState{Version=999,Visited=new List<string>{a}}).Visited.Count==0,"unknown schema rejected");
        Check(PassRules.Normalize(new JourneyState{Visited=null}).Visited.Count==0,"null list normalized");
        foreach(float endpoint in new[]{0f,750f})Check(PassRules.Normalize(new JourneyState{BikeS=endpoint}).BikeS==endpoint,"route endpoint accepted");
        Console.WriteLine("DOMAIN PASS: "+count+" assertions; actual pure C# Domain only, not Unity compile/runtime.");
    }
}
