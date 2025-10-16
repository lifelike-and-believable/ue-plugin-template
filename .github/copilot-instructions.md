## Quick orientation

This repository is an Unreal Engine plugin template with a small sample plugin located in `Plugins/SamplePlugin`. The repo contains:

- `Plugins/SamplePlugin/Source/...` — plugin modules (runtime, editor, tests). Look for `*.Build.cs` to understand module dependencies.
- `ProjectSandbox/ProjectSandbox.uproject` — a tiny test project used by CI and local manual testing.
- `Build/Scripts` — cross-platform helper scripts (PowerShell and a few bash shims) used to link the plugin into the sandbox, setup UE, build the plugin, and run automation tests.
- `Tests/Gauntlet` — gauntlet configuration used by nightly CI.

When editing code, prefer modifying plugin code under `Plugins/SamplePlugin/Source/SamplePlugin` or `SamplePluginEditor`. Tests live under `SamplePluginTests/Private`.

## High-level architecture / why things are organized this way

- Single-repo plugin development: The plugin source lives in `Plugins/` to allow both developing the plugin in-place and linking it into the `ProjectSandbox` for running the editor and automation tests.
- Small sandbox project (`ProjectSandbox`) simplifies CI and local test runs; CI uses scripts to link the plugin into that sandbox before building/running tests.
- Build scripts centralize platform-specific steps (UE setup, UBT invocation, packaging). See `Build/Scripts/Build-Plugin.ps1` and `Link-PluginIntoSandbox.ps1` for the typical flow.

## Useful commands (taken from `Docs/README.md`)

- Link plugin into sandbox (Windows PowerShell):
  - `powershell Build/Scripts/Link-PluginIntoSandbox.ps1`
- Setup Unreal Engine on CI/local (Windows PowerShell):
  - `powershell Build/Scripts/Setup-UE.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6"`
- Build the plugin (Windows PowerShell):
  - `powershell Build/Scripts/Build-Plugin.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6" -PluginUPluginPath "$PWD\Plugins\SamplePlugin\SamplePlugin.uplugin" -OutDir "$PWD\Artifacts\Win64" -TargetPlatforms @("Win64")`
- Run automation tests (Windows PowerShell):
  - `powershell Build/Scripts/Run-AutomationTests.ps1 -UEPath "C:\Program Files\Epic Games\UE_5.6" -ProjectFile "$PWD\ProjectSandbox\ProjectSandbox.uproject" -TestFilter "SamplePlugin.*" -ResultsDir "$PWD\Artifacts\Tests"`

Note: The repo's CI is centered on Windows/PowerShell. There are some bash helpers (e.g., `link_plugin_into_sandbox.sh`) but the authoritative scripts are the PowerShell ones used by CI.

## Project-specific conventions and patterns

- Module layout: each module has a `*.Build.cs` in the module directory (example: `Plugins/SamplePlugin/Source/SamplePlugin/SamplePlugin.Build.cs`). Use these files to discover module dependencies and preprocessor defines.
- Editor vs Runtime modules: Editor-only code lives in `SamplePluginEditor` and will only be built for editor targets.
- Tests: Unit/automation tests are placed under `SamplePluginTests/Private`. Small smoke tests are present (e.g., `SamplePluginSmokeTest.cpp`). Tests are run via the automation test runner (scripts above) and Gauntlet for larger scenarios.
- Naming: Test filters follow the pattern used by automation tests; examples in `Docs/README.md` use `SamplePlugin.*`.

## Integration points / external dependencies

- Unreal Engine: the repo expects an installed UE (5.6 referenced in docs). Scripts accept a `-UEPath` argument pointing to the installation.
- CI: The repository contains workflows that trigger on PRs and comments (see `Docs/README.md` for `/build` comment usage). The CI uses the same PowerShell scripts.
- Packaging & Gauntlet: `Tests/Gauntlet` contains configuration for nightly runs. Use Gauntlet when adding larger e2e tests.

## Where to change behavior

- To add a new runtime module: create a new folder under `Plugins/SamplePlugin/Source/<ModuleName>` and add a `<ModuleName>.Build.cs`.
- To add editor functionality: add an `Editor` module under `SamplePluginEditor` with an appropriate `Build.cs` and module rules.
- To extend CI commands or test runner flags: edit the PowerShell scripts under `Build/Scripts`.

## Examples to reference

- Build rules: `Plugins/SamplePlugin/Source/SamplePlugin/SamplePlugin.Build.cs`
- Editor rules: `Plugins/SamplePlugin/Source/SamplePluginEditor/SamplePluginEditor.Build.cs`
- Smoke test example: `Plugins/SamplePlugin/Source/SamplePluginTests/Private/SamplePluginSmokeTest.cpp`
- CI/test scripts: `Build/Scripts/Build-Plugin.ps1`, `Build/Scripts/Run-AutomationTests.ps1`, `Build/Scripts/Link-PluginIntoSandbox.ps1`

## Agent guidelines (do this first)

1. Read the `Build/Scripts` PowerShell scripts before making changes that affect build or test steps.
2. When adding or modifying modules, update corresponding `*.Build.cs` files and verify the module name matches folder/name conventions.
3. Use `ProjectSandbox` and scripts to locally reproduce CI behavior; prefer running the same PowerShell commands the CI runs.

If anything in these notes is unclear or you'd like more examples (CI workflow filenames, exact script flags, or sample run outputs), tell me which area to expand and I'll iterate.
