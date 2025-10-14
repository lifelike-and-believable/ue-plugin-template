using UnrealBuildTool;

public class SamplePluginTests : ModuleRules
{
    public SamplePluginTests(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PrivateDependencyModuleNames.AddRange(new[] {"Core","CoreUObject","Engine","SamplePlugin"});
    }
}
