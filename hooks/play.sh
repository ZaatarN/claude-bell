#!/usr/bin/env bash
# claude-bell: play a notification sound in the background.
#
# Usage: play.sh <path-to-wav>
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

# macOS: afplay ships with every install.
if command -v afplay >/dev/null 2>&1; then
  play_with afplay
  exit 0
fi

# Linux: try common players in order of likelihood on a modern desktop.
for player in paplay aplay pw-play ffplay; do
  if command -v "$player" >/dev/null 2>&1; then
    case "$player" in
      ffplay) play_with ffplay -nodisp -autoexit -loglevel quiet ;;
      *)      play_with "$player" ;;
    esac
    exit 0
  fi
done

exit 0
