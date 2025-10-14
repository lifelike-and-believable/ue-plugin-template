using UnrealBuildTool;

public class SamplePlugin : ModuleRules
{
    public SamplePlugin(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new[] {"Core","CoreUObject","Engine"});
    }
}
