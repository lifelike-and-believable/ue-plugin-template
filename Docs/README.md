UE Plugin Template (SamplePlugin)

- Repo-root plugin source
- Tiny sandbox
- CI: PR build+tests, Nightly (Gauntlet), Release packaging

Quickstart (Windows):
  1. pwsh Build/Scripts/Link-PluginIntoSandbox.ps1
  2. pwsh Build/Scripts/Setup-UE.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6"
  3. pwsh Build/Scripts/Build-Plugin.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6" -PluginUPluginPath "$PWD\Plugins\SamplePlugin\SamplePlugin.uplugin" -OutDir "$PWD\Artifacts\Win64" -TargetPlatforms @("Win64")
  4. pwsh Build/Scripts/Run-AutomationTests.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6" -ProjectFile "$PWD\ProjectSandbox\ProjectSandbox.uproject" -TestFilter "SamplePlugin.*" -ResultsDir "$PWD\Artifacts\Tests"
