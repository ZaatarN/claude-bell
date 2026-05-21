# 🔔 claude-bell

**Hotel desk bell notifications for Claude Code.**
One bell means Claude needs you. Two bells means Claude is done.

No background processes, no daemons, no dependencies — just three short
`.wav` files and three hook entries in your `~/.claude/settings.json`.

---

## Install

```bash
git clone https://github.com/<your-username>/claude-bell.git
cd claude-bell
./install.sh
```

Then **restart Claude Code** so it picks up the new hooks.

The installer:
- copies `play.sh` and the bell sounds to `~/.claude/bell/`
- merges three hook entries into `~/.claude/settings.json` (existing
  settings and other hooks are preserved)
- adds a single `permissions.allow` entry so the player can run silently

It's safe to re-run. Existing sound files in `~/.claude/bell/sounds/`
are kept so customizations survive an upgrade.

---

## What each sound means

| Sound | Event | Meaning |
|---|---|---|
| `attention.wav` (1 bell) | `Notification` | Claude needs your attention |
| `permission.wav` (1 lower bell) | `PermissionRequest` | Claude is asking for approval |
| `done.wav` (2 bells, ding-ding) | `Stop` | Claude has finished its turn |

The `Notification` and `PermissionRequest` bells are single chimes with
slightly different pitches so you can tell them apart by ear without
looking at the terminal. `Stop` is two bells — a clear "I'm done."

---

## Customize sounds

Swap any `.wav` in `~/.claude/bell/sounds/` with your own audio. The
hook only cares about the filename, not what's inside.

```bash
cp my-bell.wav ~/.claude/bell/sounds/attention.wav
```

Tips:
- Keep single chimes under ~500 ms so they don't overlap your next action.
- WAV (16-bit, 44.1 kHz mono) is the safest format across `afplay`,
  `paplay`, and `aplay`.

**macOS voice clips** with the built-in `say` command:

```bash
say -v Samantha "Claude is done" -o ~/.claude/bell/sounds/done.aiff
afconvert ~/.claude/bell/sounds/done.aiff ~/.claude/bell/sounds/done.wav -d LEI16
```

(See [`sounds/README.md`](sounds/README.md) for more.)

---

## Uninstall

```bash
./uninstall.sh
```

Removes only the claude-bell entries from `settings.json` (other hooks
and permissions you've added are untouched) and deletes `~/.claude/bell/`.

---

## How it works

Claude Code fires lifecycle events — `Notification`, `PermissionRequest`,
`Stop`, etc. — that you can hook into via `~/.claude/settings.json`.
claude-bell registers one `command`-type hook per event that calls
`play.sh` with the path to a `.wav`.

`play.sh` picks the first available audio player:

1. `afplay` — ships with macOS
2. `paplay` — PulseAudio
3. `aplay` — ALSA
4. `pw-play` — PipeWire
5. `ffplay` — universal fallback

Playback runs in the background and detaches from the parent shell, so
Claude Code is never blocked. If no player is available or the file is
missing, the hook exits silently — it never disrupts your session.

Requirements: bash and python3, both of which ship with macOS by
default. No npm, no Homebrew packages, no Node.

---

## License

[MIT](LICENSE).
