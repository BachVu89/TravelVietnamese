using UnrealBuildTool;
public class TravelVietnamese : ModuleRules
{
    public TravelVietnamese(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new string[] {
            "Core", "CoreUObject", "Engine", "InputCore", "ProceduralMeshComponent"
        });
    }
}
