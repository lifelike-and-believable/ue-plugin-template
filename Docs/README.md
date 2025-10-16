UE Plugin Template (SamplePlugin)

- Repo-root plugin source
- Tiny sandbox
- CI: PR build+tests, Nightly (Gauntlet), Release packaging

Quickstart (Windows):
  1. powershell Build/Scripts/Link-PluginIntoSandbox.ps1
  2. powershell Build/Scripts/Setup-UE.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6"
  3. powershell Build/Scripts/Build-Plugin.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6" -PluginUPluginPath "$PWD\Plugins\SamplePlugin\SamplePlugin.uplugin" -OutDir "$PWD\Artifacts\Win64" -TargetPlatforms @("Win64")
  4. powershell Build/Scripts/Run-AutomationTests.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6" -ProjectFile "$PWD\ProjectSandbox\ProjectSandbox.uproject" -TestFilter "SamplePlugin.*" -ResultsDir "$PWD\Artifacts\Tests"

CI trigger via PR comment:

- To request a CI run for a pull request, comment the following on the PR:

  /build

- The `agent-ci.yml` workflow listens for issue comments and will run when a comment containing `/build` is created on a pull request. This runs the same build & optional tests as the normal push/workflow_dispatch triggers.
