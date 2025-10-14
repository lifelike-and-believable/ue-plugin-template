param([string]$UEPath,[string]$PluginUPluginPath,[string]$OutDir,[string[]]$TargetPlatforms=@("Win64"),[string]$Configuration="Development")
$platforms = $TargetPlatforms -join ","
& "$UEPath\Engine\Build\BatchFiles\RunUAT.bat" BuildPlugin `
  -Plugin="$PluginUPluginPath" `
  -Package="$OutDir" `
  -TargetPlatforms=$platforms `
  -Configuration=$Configuration `
  -VS2022
exit $LASTEXITCODE
