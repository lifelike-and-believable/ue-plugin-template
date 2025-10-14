param([string]$UEPath,[string]$ProjectFile,[string[]]$GauntletConfigs,[string]$OutputDir="Artifacts\Gauntlet",[switch]$NullRHI)
$UAT = Join-Path $UEPath "Engine\Build\BatchFiles\RunUAT.bat"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$cfgs = $GauntletConfigs -join ","
$extra = $NullRHI.IsPresent ? "-NullRHI" : ""
& $UAT RunGauntlet -Project="$ProjectFile" -Config="$cfgs" -ReportDir="$OutputDir" $extra
exit $LASTEXITCODE
