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
        Check(!CameraOcclusionRules.ShouldIgnore(false,false),"world obstacle retained");
        Check(CameraOcclusionRules.ShouldIgnore(true,false),"trigger ignored");
        Check(CameraOcclusionRules.ShouldIgnore(false,true),"active or parked owned collider ignored");
        Check(CameraOcclusionRules.ShouldIgnore(true,true),"owned trigger ignored");
        float radius=CameraOcclusionRules.CollisionRadius(.12f,69,16f/9);
        Check(radius>=.28f,"minimum camera sphere radius");
        foreach(float aspect in new[]{.5625f,1f,16f/9,2.4f}) {
            float r=CameraOcclusionRules.CollisionRadius(.5f,100,aspect);
            double half=.5*Math.Tan(100*Math.PI/360);
            double corner=Math.Sqrt(.25+half*half*(1+aspect*aspect));
            Check(r>=corner,"sphere contains near-plane corner "+aspect);
        }
        Check(CameraOcclusionRules.CollisionRadius(.5f,100,2.4f)>CameraOcclusionRules.CollisionRadius(.5f,100,1),"wide screen requires bigger sphere");
        Check(CameraOcclusionRules.AllowedDistance(7,float.PositiveInfinity,.08f)==7,"no world hit preserves desired arm");
        Check(Math.Abs(CameraOcclusionRules.AllowedDistance(7,.3f,.08f)-.22f)<.0001,"near wall no old half-metre overshoot");
        Check(CameraOcclusionRules.AllowedDistance(7,20,.08f)==7,"far hit never extends camera");
        Check(CameraOcclusionRules.AllowedDistance(7,0,.08f)==0,"zero distance hit never pushed beyond obstacle");
        Check(CameraOcclusionRules.AllowedDistance(7,.03f,.08f)==0,"wall closer than margin never overshot");
        Check(Math.Abs(CameraOcclusionRules.RecoverDistance(0,7,.05f,6,false)-.3f)<.0001,"zero arm valid and recovers gradually");
        Check(CameraOcclusionRules.RecoverDistance(1,0,.016f,6,false)==0,"zero clearance retracts all way to pivot");
        Check(CameraOcclusionRules.RecoverDistance(7,1,.016f,6,false)==1,"inward collision retracts immediately");
        Check(Math.Abs(CameraOcclusionRules.RecoverDistance(1,7,.05f,6,false)-1.3f)<.0001,"outward recovery bounded by speed");
        Check(CameraOcclusionRules.RecoverDistance(1,7,0,6,false)==1,"zero delta does not extend");
        Check(CameraOcclusionRules.RecoverDistance(1,7,-1,6,false)==1,"negative delta ignored");
        Check(CameraOcclusionRules.RecoverDistance(1,7,.016f,6,true)==7,"mode reset snaps without old distance");
        Check(CameraOcclusionRules.RecoverDistance(6.9f,7,.1f,6,false)==7,"recovery no overshoot");
        foreach(float invalid in new[]{float.NaN,float.PositiveInfinity,float.NegativeInfinity}) {
            Check(PassRules.Finite(CameraOcclusionRules.CollisionRadius(invalid,invalid,invalid)),"invalid lens finite");
            Check(PassRules.Finite(CameraOcclusionRules.AllowedDistance(invalid,invalid,invalid)),"invalid arm finite");
            Check(PassRules.Finite(CameraOcclusionRules.RecoverDistance(invalid,invalid,invalid,invalid,false)),"invalid recovery finite");
        }
        Console.WriteLine("DOMAIN PASS: "+count+" assertions; actual pure C# Domain only, not Unity compile/runtime.");
    }
}
