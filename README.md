# 🔔 claude-bell

**Hotel desk bell notifications for Claude Code.**
One bell means Claude needs you. Two bells means Claude is done.

No background processes, no daemons, no dependencies — just three short
`.mp3` files and three hook entries in your `~/.claude/settings.json`.

> **Bring your own sounds.** The repo ships with placeholder bells so
> you can install and try the hooks immediately, but they're meant to
> be replaced. Drop your own `.mp3`s into `~/.claude/bell/sounds/`
> (same filenames) any time after install — see
> [Customize sounds](#customize-sounds).

---

## Install

```bash
git clone https://github.com/ZaatarN/claude-bell.git
cd claude-bell
./install.sh
```

Then **restart Claude Code** so it picks up the new hooks.

The installer:
- copies `play.sh` and the placeholder sounds to `~/.claude/bell/`
- merges three hook entries into `~/.claude/settings.json` (existing
  settings and other hooks are preserved)
- adds a single `permissions.allow` entry so the player can run silently

It's safe to re-run. Existing sound files in `~/.claude/bell/sounds/`
are kept so your custom sounds survive an upgrade.

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

The bundled `.mp3`s are placeholders. Replace any of them in
`~/.claude/bell/sounds/` with your own audio — the hook only cares
about the filename, not what's inside.

```bash
cp my-bell.mp3 ~/.claude/bell/sounds/attention.mp3
```

Tips:
- Keep single chimes under ~500 ms so they don't overlap your next action.
- `.mp3` plays natively under `afplay` on macOS and `mpg123` / `ffplay`
  on Linux. `.wav` and `.m4a` also work — just rename to match (e.g.
  `attention.mp3` → `attention.wav`) and update the hook command in
  `~/.claude/settings.json`.

**macOS voice clips** with the built-in `say` command:

```bash
say -v Samantha "Claude is done" -o /tmp/done.aiff
afconvert /tmp/done.aiff ~/.claude/bell/sounds/done.mp3 -d aac -f m4af
# or, if you prefer real mp3, use `lame` / `ffmpeg` once installed.
```

(See [`sounds/README.md`](sounds/README.md) for more tips and free
sound sources.)

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
`play.sh` with the path to an audio file.

`play.sh` picks the first available audio player:

1. `afplay` — ships with macOS, plays `.mp3` natively
2. `mpg123` — dedicated MP3 decoder on Linux
3. `ffplay` — universal fallback (handles anything ffmpeg does)
4. `mpv`, `cvlc` — common modern players
5. `paplay` / `aplay` / `pw-play` — last-resort for WAV-only setups

Playback runs in the background and detaches from the parent shell, so
Claude Code is never blocked. If no player is available or the file is
missing, the hook exits silently — it never disrupts your session.

Requirements: bash and python3, both of which ship with macOS by
default. No npm, no Homebrew packages, no Node.

---

## License

[MIT](LICENSE).
