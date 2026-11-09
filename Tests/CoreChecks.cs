using System;
using System.Collections.Generic;
using VietTrail.Core;
static class CoreChecks
{
    static int total;
    static void Require(bool result,string reason){total++;if(!result)throw new Exception(reason);}
    static void Main()
    {
        var state=new JourneyState();
        Require(!RideRules.Discover(state,1,false,0),"second visit must wait for first");
        Require(!RideRules.Discover(state,0,true,0),"riding cannot discover");
        foreach(float d in new[]{-1f,3.01f,float.NaN,float.PositiveInfinity})Require(!RideRules.Discover(state,0,false,d),"invalid discovery distance");
        Require(!RideRules.Discover(state,-1,false,0)&&!RideRules.Discover(state,3,false,0),"unknown stop rejected");
        Require(state.visited.Count==0,"failed actions cannot mutate progress");
        for(int i=0;i<3;i++){
            Require(RideRules.Discover(state,i,false,3),"visit at inclusive boundary");
            Require(!RideRules.Discover(state,i,false,0),"stamp awarded once");
        }
        Require(state.visited.Count==3,"exactly three local discoveries");
        Require(!RideRules.Discover(null,0,false,0),"null state rejected");
        Require(!RideRules.Discover(new JourneyState{visited=null},0,false,0),"null visited rejected");
        foreach(float n in new[]{float.NaN,float.NegativeInfinity,float.PositiveInfinity}){
            Require(!RideRules.CanMount(n),"nonfinite mount rejected");
            Require(!RideRules.CanDismount(n,260,5),"nonfinite speed rejected");
            Require(!RideRules.InBay(n,5),"nonfinite station rejected");
            Require(!RideRules.InBay(260,n),"nonfinite lane rejected");
        }
        foreach(float stop in new[]{260f,640f,1100f}){
            Require(RideRules.CanDismount(0,stop-12,6.5f)&&RideRules.CanDismount(0,stop+12,3.6f),"full flat bay endpoints inclusive");
            Require(!RideRules.CanDismount(0,stop-12.01f,6.5f)&&!RideRules.CanDismount(0,stop+12.01f,6.5f),"taper outside full bay rejected");
        }
        Require(RideRules.CanMount(0)&&RideRules.CanMount(2.5f),"mount distance inclusive");
        Require(!RideRules.CanMount(-.01f)&&!RideRules.CanMount(2.501f),"mount distance outside range");
        Require(RideRules.CanDismount(.35f,260,5),"stopped threshold inclusive");
        Require(!RideRules.CanDismount(.351f,260,5)&&!RideRules.CanDismount(-1,260,5),"dismount moving/negative speed blocked");
        Require(!RideRules.CanDismount(0,260,3.59f)&&!RideRules.CanDismount(0,260,6.51f),"dismount outside bay lane blocked");
        float[] stations={0,259.99f,260,639.99f,640,1099.99f,1100,1600};
        float[] checkpoints={8,8,260,260,640,640,1100,1100};
        for(int i=0;i<stations.Length;i++)Require(RideRules.Checkpoint(stations[i])==checkpoints[i],"checkpoint cannot advance to unpassed stop");
        Require(RideRules.Normalize(null).meters==8,"missing save defaults");
        Require(RideRules.Normalize(new JourneyState{version=8,meters=500}).meters==8,"unsupported version defaults");
        var incoming=new JourneyState{meters=640,lane=5,visited=new List<string>{"tea_hill","tea_hill","cloud_turn","bad"},options=new JourneyOptions{music=2,sfx=-1,quality=4,bikeColor=-5}};
        var clean=RideRules.Normalize(incoming);
        Require(clean.meters==640&&clean.lane==5,"valid pose retained");
        Require(clean.visited.Count==2,"duplicate/unknown stamps canonicalized");
        Require(clean.options.music==1&&clean.options.sfx==0&&clean.options.quality==1&&clean.options.bikeColor==0,"settings normalized independently");
        Require(incoming.visited.Count==4&&incoming.options.music==2,"normalizer cannot mutate input");
        clean.visited.Clear();Require(incoming.visited.Count==4,"normalized list independent");
        Require(RideRules.Normalize(new JourneyState{visited=new List<string>{"cloud_turn"}}).visited.Count==0,"orphan second stamp removed");
        foreach(float bad in new[]{-1f,1600.1f,float.NaN,float.PositiveInfinity}){
            var normal=RideRules.Normalize(new JourneyState{meters=bad,lane=5,visited=new List<string>{"tea_hill"}});
            Require(normal.meters==8&&normal.lane==1.2f&&normal.visited.Count==1,"invalid pose does not delete valid stamp");
        }
        var malformed=RideRules.Normalize(new JourneyState{meters=500,lane=6,options=new JourneyOptions{music=float.NaN,sfx=float.PositiveInfinity}});
        Require(malformed.lane==1.2f&&malformed.options.music==.65f&&malformed.options.sfx==.8f,"unsafe lane and nonfinite preferences corrected");
        for(int station=0;station<=1600;station+=8){
            var first=RideRules.Normalize(new JourneyState{meters=station,lane=5});var second=RideRules.Normalize(first);
            Require(first.meters==second.meters&&first.lane==second.lane,"normalization idempotent across route");
        }
        Console.WriteLine("CORE PASS: "+total+" assertions on actual pure C# source; not Unity compile/gameplay/graphics.");
    }
}
