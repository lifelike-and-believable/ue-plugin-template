param(
  [string]$UEPath,
  [string]$PluginUPluginPath,
  [string]$OutDir,
  [string[]]$TargetPlatforms = @("Win64"),
  [string]$Configuration = "Development"
)

# Sanitize and normalize inputs
$UEPath = $UEPath.Trim('"', "'")
$PluginUPluginPath = $PluginUPluginPath.Trim('"', "'")
$OutDir = $OutDir.Trim('"', "'")
$TargetPlatforms = $TargetPlatforms | ForEach-Object { $_.Trim('"', "'") }
$platforms = ($TargetPlatforms -join ",")

$UAT = Join-Path -Path $UEPath -ChildPath "Engine\Build\BatchFiles\RunUAT.bat"
if (!(Test-Path -LiteralPath $UAT)) {
  Write-Error "RunUAT not found under $UEPath"
  exit 1
}

$PluginUPluginPath = (Resolve-Path -LiteralPath $PluginUPluginPath).Path
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path

# Pass each UAT option as a single token so PowerShell doesn't split values with spaces
& $UAT BuildPlugin `
  "-Plugin=$PluginUPluginPath" `
  "-Package=$OutDir" `
  "-TargetPlatforms=$platforms" `
  "-Configuration=$Configuration" `
  -Rocket `
  -VeryVerbose `
  -VS2022

exit $LASTEXITCODE
