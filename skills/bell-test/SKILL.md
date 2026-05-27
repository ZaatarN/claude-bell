---
name: bell-test
description: Test claude-bell notification sounds to verify audio setup
argument-hint: "[attention | permission | done]"
allowed-tools:
  - Bash
  - PowerShell
---

# Bell Test

Play the claude-bell notification sounds to verify audio works on this machine.

## Instructions

If no argument is given, play all three sounds in order with a 2-second pause between each. Report what you played:

1. **attention** — `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/play.py" "${CLAUDE_PLUGIN_ROOT}/sounds/attention.mp3"`
2. Wait 2 seconds
3. **permission** — `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/play.py" "${CLAUDE_PLUGIN_ROOT}/sounds/permission.mp3"`
4. Wait 2 seconds
5. **done** — `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/play.py" "${CLAUDE_PLUGIN_ROOT}/sounds/done.mp3"`

If an argument is given (`$ARGUMENTS`), play only that sound:
- `attention` or `notification` → attention.mp3
- `permission` → permission.mp3
- `done` or `stop` → done.mp3

Ask the user if they heard the sounds. If not, check whether `python3` is on PATH and whether any audio player is available (`afplay` on macOS, `mpg123`/`ffplay` on Linux, PowerShell on Windows).
