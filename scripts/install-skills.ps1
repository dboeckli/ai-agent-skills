#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot    = Split-Path -Parent $ScriptDir
$SkillsSrc      = Join-Path $PackageRoot '.claude\skills'
$SkillsDest     = Join-Path $HOME '.claude\skills'
$StatuslineSrc  = Join-Path $PackageRoot 'scripts\statusline.sh'
$StatuslineDest = Join-Path $HOME '.claude\statusline.sh'
$FormatSh       = Join-Path $PackageRoot '.claude\hooks\format.sh'
$Settings       = Join-Path $HOME '.claude\settings.json'

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

# Copy statusline.sh
if (Test-Path $StatuslineSrc) {
    Copy-Item -Force $StatuslineSrc $StatuslineDest
    Write-Host "  Installed: statusline.sh"
}

# Add Stop hook to settings.json
if ((Test-Path $Settings) -and (Test-Path $FormatSh)) {
    # Use forward slashes so bash (Git Bash / WSL) can resolve the path
    $forwardSlashPath = $FormatSh -replace '\\', '/'
    $hookCommand      = "bash `"$forwardSlashPath`""

    $settings = Get-Content -Raw -Path $Settings | ConvertFrom-Json

    # ['key'] indexer is safe in strict mode; .Properties.Name member-enumeration is not
    if (-not $settings.PSObject.Properties['hooks'] -or $null -eq $settings.hooks) {
        $settings | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([PSCustomObject]@{}) -Force
    }
    if (-not $settings.hooks.PSObject.Properties['Stop']) {
        $settings.hooks | Add-Member -MemberType NoteProperty -Name 'Stop' -Value @()
    }

    $stopHooks = @($settings.hooks.Stop)
    $already   = $false
    foreach ($entry in $stopHooks) {
        if (-not $entry.PSObject.Properties['hooks']) { continue }
        foreach ($h in @($entry.hooks)) {
            if ($h.PSObject.Properties['command'] -and $h.command -eq $hookCommand) {
                $already = $true; break
            }
        }
        if ($already) { break }
    }

    if (-not $already) {
        $newEntry = [PSCustomObject]@{
            hooks = @(
                [PSCustomObject]@{
                    type          = 'command'
                    command       = $hookCommand
                    statusMessage = 'Formatting files...'
                }
            )
        }
        $settings.hooks.Stop = @($stopHooks) + @($newEntry)
        $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $Settings -Encoding UTF8
        Write-Host "  Installed: Stop hook (format.sh)"
    } else {
        Write-Host "  Stop hook already present"
    }
}

Write-Host "Done."
