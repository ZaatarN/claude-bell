---
name: bell-sounds
description: Show how to customize claude-bell notification sounds
allowed-tools:
  - Bash
  - PowerShell
  - Read
---

# Bell Sounds

Explain how to customize the notification sounds used by claude-bell.

## Instructions

Tell the user:

### Default sounds

The plugin ships with three placeholder bell sounds:

| File | Event | Character |
|---|---|---|
| `attention.mp3` | Notification | Single bright bell |
| `permission.mp3` | PermissionRequest | Single lower bell |
| `done.mp3` | Stop | Two bells (ding-ding) |

### Custom sounds

Set the `CLAUDE_BELL_SOUNDS_DIR` environment variable to a directory containing your own sound files with the same names. The plugin checks there first and falls back to the bundled sounds.

Example (add to your shell profile):
```bash
export CLAUDE_BELL_SOUNDS_DIR="$HOME/.config/claude-bell/sounds"
```

Then place your custom `attention.mp3`, `permission.mp3`, and/or `done.mp3` in that directory.

### Tips

- Keep chimes under ~500 ms so they don't feel laggy.
- MP3 works everywhere. WAV, M4A, and OGG also work on most systems.
- Free sources: [Freesound.org](https://freesound.org), [Mixkit](https://mixkit.co/free-sound-effects/bell/), [SampleFocus](https://samplefocus.com).
- On macOS you can generate voice clips: `say -v Samantha "Claude is done" -o done.aiff`
