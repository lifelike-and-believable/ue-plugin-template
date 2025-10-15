$ScriptRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptRoot

$PluginPath = Join-Path $RepoRoot "Plugins\SamplePlugin"
$SandboxPath = Join-Path $RepoRoot "ProjectSandbox"
$dst = Join-Path $SandboxPath "Plugins\SamplePlugin"

if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
cmd /c "mklink /J ""$dst"" ""$PluginPath"""
Write-Host "Linked plugin into sandbox: $dst"
