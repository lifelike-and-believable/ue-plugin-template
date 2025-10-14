#include "Misc/AutomationTest.h"
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FSamplePluginSmoke, "SamplePlugin.Smoke", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FSamplePluginSmoke::RunTest(const FString& Params)
{
    TestTrue(TEXT("Plugin basic assertion"), true);
    return true;
}
