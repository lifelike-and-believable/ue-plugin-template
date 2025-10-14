param(
    [Parameter(Mandatory=$true)]
    [string]$NewPluginName,
    
    [Parameter(Mandatory=$false)]
    [string]$UEVersion = "5.6"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to validate plugin name
function Test-PluginName {
    param([string]$Name)
    
    # Check if name is empty
    if ([string]::IsNullOrWhiteSpace($Name)) {
        throw "Plugin name cannot be empty"
    }
    
    # Check if name follows PascalCase convention (starts with uppercase, alphanumeric only)
    # Use -cnotmatch for case-sensitive matching
    if ($Name -cnotmatch '^[A-Z][a-zA-Z0-9]*$') {
        throw "Plugin name must follow PascalCase convention (start with uppercase letter, alphanumeric only, no spaces or special characters)"
    }
    
    return $true
}

# Function to replace text in file
function Replace-InFile {
    param(
        [string]$FilePath,
        [string]$OldText,
        [string]$NewText
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        $newContent = $content -creplace $OldText, $NewText
        if ($content -ne $newContent) {
            Set-Content -Path $FilePath -Value $newContent -Encoding UTF8 -NoNewline
            Write-Host "  Updated content in: $FilePath"
        }
    }
}

# Get the repository root (two levels up from script directory)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

Write-Host "Repository root: $RepoRoot"
Write-Host "New plugin name: $NewPluginName"
Write-Host "UE version: $UEVersion"
Write-Host ""

# Validate plugin name
try {
    Test-PluginName -Name $NewPluginName
} catch {
    Write-Error $_
    exit 1
}

# Check for existing plugin directories
$PluginsDir = Join-Path $RepoRoot "Plugins"
$SamplePluginDir = Join-Path $PluginsDir "SamplePlugin"
$NewPluginDir = Join-Path $PluginsDir $NewPluginName

# Idempotency check: if the target already exists and source doesn't, assume already renamed
if ((Test-Path $NewPluginDir) -and (-not (Test-Path $SamplePluginDir))) {
    Write-Host "Plugin appears to already be renamed to '$NewPluginName'."
    Write-Host "Skipping directory renaming, but will still update engine version and other settings."
    Write-Host ""
    $SamplePluginDir = $NewPluginDir
    $SkipRename = $true
} elseif (-not (Test-Path $SamplePluginDir)) {
    Write-Error "SamplePlugin directory not found at: $SamplePluginDir"
    exit 1
} else {
    $SkipRename = $false
}

if (-not $SkipRename) {
    Write-Host "Step 1: Renaming directories..."
    Write-Host "================================"

    # Rename plugin directory
    if ($SamplePluginDir -ne $NewPluginDir) {
        if (Test-Path $NewPluginDir) {
            Write-Host "  Target directory already exists: $NewPluginDir (skipping rename)"
        } else {
            Move-Item -LiteralPath $SamplePluginDir -Destination $NewPluginDir
            Write-Host "  Renamed: Plugins/SamplePlugin -> Plugins/$NewPluginName"
        }
        $SamplePluginDir = $NewPluginDir
    }

    # Rename source directories within the plugin
    $SourceDir = Join-Path $SamplePluginDir "Source"
    if (Test-Path $SourceDir) {
        # Rename SamplePlugin source directory
        $OldSourcePath = Join-Path $SourceDir "SamplePlugin"
        $NewSourcePath = Join-Path $SourceDir $NewPluginName
        if ((Test-Path $OldSourcePath) -and ($OldSourcePath -ne $NewSourcePath)) {
            if (Test-Path $NewSourcePath) {
                Write-Host "  Target directory already exists: $NewSourcePath (skipping rename)"
            } else {
                Move-Item -LiteralPath $OldSourcePath -Destination $NewSourcePath
                Write-Host "  Renamed: Source/SamplePlugin -> Source/$NewPluginName"
            }
        }
        
        # Rename SamplePluginEditor source directory
        $OldEditorPath = Join-Path $SourceDir "SamplePluginEditor"
        $NewEditorPath = Join-Path $SourceDir "${NewPluginName}Editor"
        if ((Test-Path $OldEditorPath) -and ($OldEditorPath -ne $NewEditorPath)) {
            if (Test-Path $NewEditorPath) {
                Write-Host "  Target directory already exists: $NewEditorPath (skipping rename)"
            } else {
                Move-Item -LiteralPath $OldEditorPath -Destination $NewEditorPath
                Write-Host "  Renamed: Source/SamplePluginEditor -> Source/${NewPluginName}Editor"
            }
        }
        
        # Rename SamplePluginTests source directory
        $OldTestsPath = Join-Path $SourceDir "SamplePluginTests"
        $NewTestsPath = Join-Path $SourceDir "${NewPluginName}Tests"
        if ((Test-Path $OldTestsPath) -and ($OldTestsPath -ne $NewTestsPath)) {
            if (Test-Path $NewTestsPath) {
                Write-Host "  Target directory already exists: $NewTestsPath (skipping rename)"
            } else {
                Move-Item -LiteralPath $OldTestsPath -Destination $NewTestsPath
                Write-Host "  Renamed: Source/SamplePluginTests -> Source/${NewPluginName}Tests"
            }
        }
    }

    Write-Host ""
    Write-Host "Step 2: Renaming files..."
    Write-Host "================================"

    # Find and rename all files with "SamplePlugin" in their names
    Get-ChildItem -Path $SamplePluginDir -Recurse -File | Where-Object { $_.Name -like "*SamplePlugin*" } | ForEach-Object {
        $oldName = $_.Name
        $newName = $oldName -replace "SamplePlugin", $NewPluginName
        if ($oldName -ne $newName) {
            $newPath = Join-Path $_.DirectoryName $newName
            if (Test-Path $newPath) {
                Write-Host "  Target file already exists: $newPath (skipping rename)"
            } else {
                Move-Item -LiteralPath $_.FullName -Destination $newPath
                Write-Host "  Renamed: $oldName -> $newName"
            }
        }
    }

    Write-Host ""
    Write-Host "Step 3: Replacing content in files..."
    Write-Host "================================"

    # Replace content in all relevant files
    $FilesToUpdate = Get-ChildItem -Path $SamplePluginDir -Recurse -Include "*.cpp","*.h","*.cs","*.uplugin" -File

    foreach ($file in $FilesToUpdate) {
        Replace-InFile -FilePath $file.FullName -OldText "SamplePlugin" -NewText $NewPluginName
    }
}

Write-Host ""
Write-Host "Step 4: Updating ProjectSandbox.uproject..."
Write-Host "================================"

$ProjectFile = Join-Path $RepoRoot "ProjectSandbox/ProjectSandbox.uproject"
if (Test-Path $ProjectFile) {
    # Read and parse JSON
    $jsonContent = Get-Content -Path $ProjectFile -Raw -Encoding UTF8 | ConvertFrom-Json
    
    # Update EngineAssociation
    $jsonContent.EngineAssociation = $UEVersion
    
    # Update Description
    $jsonContent.Description = "Sandbox for $NewPluginName"
    
    # Update plugin name in Plugins array
    if ($jsonContent.Plugins) {
        foreach ($plugin in $jsonContent.Plugins) {
            if ($plugin.Name -eq "SamplePlugin" -or $plugin.Name -eq $NewPluginName) {
                $plugin.Name = $NewPluginName
            }
        }
    }
    
    # Write back to file with proper formatting
    $jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $ProjectFile -Encoding UTF8
    Write-Host "  Updated: ProjectSandbox.uproject"
    Write-Host "    - EngineAssociation: $UEVersion"
    Write-Host "    - Plugin name: $NewPluginName"
}

Write-Host ""
Write-Host "Step 5: Updating README.md..."
Write-Host "================================"

$ReadmeFile = Join-Path $RepoRoot "Docs/README.md"
if (Test-Path $ReadmeFile) {
    Replace-InFile -FilePath $ReadmeFile -OldText "SamplePlugin" -NewText $NewPluginName
    Write-Host "  Updated: Docs/README.md"
}

Write-Host ""
Write-Host "Step 6: Updating Tests/Gauntlet configuration..."
Write-Host "================================"

$GauntletDir = Join-Path $RepoRoot "Tests/Gauntlet"
if (Test-Path $GauntletDir) {
    Get-ChildItem -Path $GauntletDir -Include "*.json" -File -Recurse | ForEach-Object {
        Replace-InFile -FilePath $_.FullName -OldText "SamplePlugin" -NewText $NewPluginName
        Write-Host "  Updated: $($_.Name)"
    }
}

Write-Host ""
Write-Host "Step 7: Updating Build/Scripts..."
Write-Host "================================"

$ScriptsDir = Join-Path $RepoRoot "Build/Scripts"
if (Test-Path $ScriptsDir) {
    # Update shell scripts
    Get-ChildItem -Path $ScriptsDir -Include "*.sh" -File -Recurse | ForEach-Object {
        Replace-InFile -FilePath $_.FullName -OldText "SamplePlugin" -NewText $NewPluginName
    }
    
    # Note: We don't update PowerShell scripts (except this one) as they use dynamic paths
    Write-Host "  Updated shell scripts"
}

Write-Host ""
Write-Host "================================"
Write-Host "Plugin rename completed successfully!"
Write-Host "================================"
Write-Host ""
Write-Host "Summary:"
Write-Host "  - Plugin name: $NewPluginName"
Write-Host "  - UE version: $UEVersion"
Write-Host "  - Plugin directory: Plugins/$NewPluginName"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review the changes"
Write-Host "  2. Run: pwsh Build/Scripts/Link-PluginIntoSandbox.ps1"
Write-Host "  3. Build and test the plugin"
Write-Host ""
