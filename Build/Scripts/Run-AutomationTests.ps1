param([string]$UEPath,[string]$ProjectFile,[string]$TestFilter="*",[string]$ResultsDir="Artifacts\Tests")
$EditorExe = Join-Path $UEPath "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
New-Item -ItemType Directory -Force -Path $ResultsDir | Out-Null
$cmds = "Automation RunTests $TestFilter; Automation WriteResults $ResultsDir\Results.xml; Quit"
& $EditorExe $ProjectFile -unattended -nop4 -NullRHI -NoSound -NoSplash -Nolog -ExecCmds=$cmds
exit $LASTEXITCODE
