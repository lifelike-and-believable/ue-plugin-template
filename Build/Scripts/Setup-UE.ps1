param([string]$UEPath = "C:\Program Files\Epic Games\UE_5.6")
if (!(Test-Path $UEPath)) { Write-Error "UE path not found: $UEPath"; exit 1 }
$UAT = Join-Path $UEPath "Engine\Build\BatchFiles\RunUAT.bat"
if (!(Test-Path $UAT)) { Write-Error "RunUAT not found under $UEPath"; exit 1 }
Write-Host "UE setup OK: $UEPath"
