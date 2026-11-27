#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot    = Split-Path -Parent $ScriptDir
$SkillsSrc      = Join-Path $PackageRoot '.agents\skills'
$SkillsDest     = Join-Path $HOME '.agents\skills'
$StatuslineSrc  = Join-Path $PackageRoot 'scripts\statusline.sh'
$StatuslineDest = Join-Path $HOME '.claude\statusline.sh'
$ClaudeDir      = Join-Path $HOME '.claude'

# Create skills destination directory
New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null

# Install skills as directory junctions (no admin rights required)
foreach ($skillDir in Get-ChildItem -Path $SkillsSrc -Directory) {
    $dest = Join-Path $SkillsDest $skillDir.Name
    if (Test-Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }
    try {
        New-Item -ItemType Junction -Path $dest -Target $skillDir.FullName | Out-Null
        Write-Host "  Linked skill: $($skillDir.Name)"
    } catch {
        # Fall back to copy if junction creation fails
        Copy-Item -Path $skillDir.FullName -Destination $dest -Recurse -Force
        Write-Host "  Copied skill: $($skillDir.Name)"
    }
}

# Optional Claude Code statusline: only install when ~/.claude already exists.
if ((Test-Path $StatuslineSrc) -and (Test-Path $ClaudeDir)) {
    Copy-Item -Force $StatuslineSrc $StatuslineDest
    Write-Host "  Installed: statusline.sh (Claude Code)"
}

Write-Host "Done."
