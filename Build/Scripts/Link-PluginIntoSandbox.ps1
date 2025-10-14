$PluginPath = "/mnt/data/ue-plugin-template\Plugins\SamplePlugin"
$SandboxPath = "/mnt/data/ue-plugin-template\ProjectSandbox"
$dst = Join-Path $SandboxPath "Plugins\SamplePlugin"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
cmd /c "mklink /J ""$dst"" ""$PluginPath"""
Write-Host "Linked plugin into sandbox: $dst"
