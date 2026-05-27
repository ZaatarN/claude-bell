# claude-bell: PowerShell player.
# Usage: play.ps1 <sound-filename>   (looked up in $HOME\.claude\bell\sounds\)
#
# Spawns a hidden child PowerShell that plays the file via WPF MediaPlayer
# and exits immediately, so Claude Code is never blocked by the hook.
# Always exits 0 — playback failures must not disrupt the calling hook.

param([Parameter(Mandatory = $true)][string]$Sound)

$ErrorActionPreference = 'SilentlyContinue'
try {
    $soundPath = Join-Path $HOME ".claude\bell\sounds\$Sound"
    if (-not (Test-Path -LiteralPath $soundPath)) { exit 0 }

    $child = @"
Add-Type -AssemblyName presentationCore
`$p = New-Object System.Windows.Media.MediaPlayer
`$p.Open([uri]'$soundPath')
`$p.Play()
Start-Sleep -Seconds 5
"@
    Start-Process -WindowStyle Hidden -FilePath powershell `
        -ArgumentList '-NoProfile', '-NonInteractive', '-Command', $child | Out-Null
} catch {}
exit 0
