#!/usr/bin/env bash
# claude-bell: play a notification sound in the background.
#
# Usage: play.sh <path-to-audio-file>
#
# Tries audio players in order of preference for the host platform.
# Exits silently (0) if the file doesn't exist, no player is available,
# or playback fails — we never want to disrupt Claude Code.

set -u

sound_file="${1:-}"

if [[ -z "$sound_file" || ! -f "$sound_file" ]]; then
  exit 0
fi

play_with() {
  # Detach so Claude Code is not blocked while the sound plays.
  ( "$@" "$sound_file" >/dev/null 2>&1 ) &
  disown 2>/dev/null || true
}

# macOS: afplay ships with every install and handles mp3 natively.
if command -v afplay >/dev/null 2>&1; then
  play_with afplay
  exit 0
fi

# Linux: prefer players that decode mp3 without extra plugins.
for player in mpg123 ffplay mpv cvlc paplay aplay pw-play; do
  if command -v "$player" >/dev/null 2>&1; then
    case "$player" in
      mpg123) play_with mpg123 -q ;;
      ffplay) play_with ffplay -nodisp -autoexit -loglevel quiet ;;
      mpv)    play_with mpv --really-quiet --no-video ;;
      cvlc)   play_with cvlc --play-and-exit --quiet ;;
      *)      play_with "$player" ;;
    esac
    exit 0
  fi
done

# Windows (Git Bash / MSYS / Cygwin): use .NET WPF MediaPlayer via PowerShell.
# Listed last so WSL still prefers native Linux players above.
if command -v powershell.exe >/dev/null 2>&1; then
  if command -v cygpath >/dev/null 2>&1; then
    win_path=$(cygpath -w "$sound_file" 2>/dev/null || printf %s "$sound_file")
  else
    win_path="$sound_file"
  fi
  (
    BELL_PATH="$win_path" powershell.exe -NoProfile -NonInteractive -Command \
      'Add-Type -AssemblyName presentationCore;
       $p = New-Object System.Windows.Media.MediaPlayer;
       $p.Open([uri]$env:BELL_PATH);
       $p.Play();
       Start-Sleep -Seconds 5' >/dev/null 2>&1
  ) &
  disown 2>/dev/null || true
  exit 0
fi

exit 0
