# claude-bell

**Hotel desk bell notifications for Claude Code.**
One bell means Claude needs you. Two bells means Claude is done.

No background processes, no daemons — just three short `.mp3` files
and a Claude Code plugin.

> **Bring your own sounds.** The plugin ships with placeholder bells so
> everything works out of the box, but they're meant to be replaced —
> see [Customize sounds](#customize-sounds).

---

## Install

```bash
claude plugin install github:ZaatarN/claude-bell
```

Then **restart Claude Code** so it picks up the new hooks.

To uninstall:

```bash
claude plugin remove claude-bell
```

### Local development

```bash
git clone https://github.com/ZaatarN/claude-bell.git
claude --plugin-dir ./claude-bell
```

---

## What each sound means

| Sound | Event | Meaning |
|---|---|---|
| `attention.mp3` (1 bell) | `Notification` | Claude needs your attention |
| `permission.mp3` (1 lower bell) | `PermissionRequest` | Claude is asking for approval |
| `done.mp3` (2 bells, ding-ding) | `Stop` | Claude has finished its turn |

The `Notification` and `PermissionRequest` bells are single chimes with
slightly different pitches so you can tell them apart by ear without
looking at the terminal. `Stop` is two bells — a clear "I'm done."

---

## Customize sounds

Set the `CLAUDE_BELL_SOUNDS_DIR` environment variable to a directory
containing your own sound files. The plugin checks there first and
falls back to the bundled sounds.

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export CLAUDE_BELL_SOUNDS_DIR="$HOME/.config/claude-bell/sounds"
```

Then drop your own `attention.mp3`, `permission.mp3`, and/or `done.mp3`
in that directory.

Tips:
- Keep single chimes under ~500 ms so they don't overlap your next action.
- `.mp3` plays natively on all platforms. `.wav` and `.m4a` also work.
- `/bell-test` plays all three sounds so you can verify your setup.
- `/bell-sounds` shows full customization details.

**macOS voice clips** with the built-in `say` command:

```bash
say -v Samantha "Claude is done" -o /tmp/done.aiff
afconvert /tmp/done.aiff ~/sounds/done.mp3 -d aac -f m4af
```

(See [`sounds/README.md`](sounds/README.md) for more tips and free
sound sources.)

---

## How it works

Claude Code fires lifecycle events — `Notification`, `PermissionRequest`,
`Stop`, etc. — that plugins can hook into. claude-bell registers one
`command`-type hook per event that calls `play.py` with the path to an
audio file.

`play.py` picks the first available audio player:

| Platform | Players (in order of preference) |
|---|---|
| macOS | `afplay` |
| Linux | `mpg123`, `ffplay`, `mpv`, `cvlc`, `paplay`, `aplay`, `pw-play` |
| Windows | PowerShell + WPF MediaPlayer |

Playback runs in the background and detaches from the parent process, so
Claude Code is never blocked. If no player is available or the file is
missing, the hook exits silently — it never disrupts your session.

Requirements: Python 3 (ships with macOS and most Linux distros; install
from [python.org](https://www.python.org/downloads/) on Windows).

---

## Migrating from script-based install

If you installed an earlier version using `install.sh`:

1. Run `./uninstall.sh` from your old clone to remove `~/.claude/bell/`
   and the old hook entries from `settings.json`
2. Install the plugin: `claude plugin install github:ZaatarN/claude-bell`
3. If you had custom sounds in `~/.claude/bell/sounds/`, move them to a
   new directory and set `CLAUDE_BELL_SOUNDS_DIR` to point there

---

## License

[MIT](LICENSE).
