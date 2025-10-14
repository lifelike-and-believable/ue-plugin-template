using UnrealBuildTool;

public class SamplePluginEditor : ModuleRules
{
    public SamplePluginEditor(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PrivateDependencyModuleNames.AddRange(new[] {"Core","CoreUObject","Engine","UnrealEd","SamplePlugin"});
    }
}
