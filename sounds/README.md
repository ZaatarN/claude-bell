# Sounds

Three short bell samples played by claude-bell hooks.

| File | When it plays | Character |
|---|---|---|
| `attention.mp3`  | `Notification` event       | Single bright bell (~3.2 kHz, ~400 ms) |
| `permission.mp3` | `PermissionRequest` event  | Single lower bell (~2.6 kHz, ~450 ms) |
| `done.mp3`       | `Stop` event               | Two bells, ding-ding (~950 ms) |

> These are placeholders. They're synthesized hotel-bell stand-ins
> so the hook works the moment you install — replace them with your own
> sounds whenever you're ready.

---

## Swap your own sounds

Set `CLAUDE_BELL_SOUNDS_DIR` to a directory with your custom files:

```bash
export CLAUDE_BELL_SOUNDS_DIR="$HOME/.config/claude-bell/sounds"
mkdir -p "$CLAUDE_BELL_SOUNDS_DIR"
cp my-chime.mp3 "$CLAUDE_BELL_SOUNDS_DIR/attention.mp3"
```

The plugin checks that directory first and falls back to the bundled
sounds for any files not found there.

### Tips

- **Keep single chimes under ~500 ms.** Anything longer overlaps your
  next prompt and feels laggy.
- **MP3 is the default**, but the player will happily play `.wav`,
  `.m4a`, `.ogg`, or anything else `afplay` / `ffplay` understands.
- **Free sources for bells, chimes, and dings:**
  [Freesound.org](https://freesound.org),
  [Mixkit](https://mixkit.co/free-sound-effects/bell/),
  [SampleFocus](https://samplefocus.com).
- **Test your sounds** with `/bell-test` inside Claude Code, or manually:

  ```bash
  afplay sounds/attention.mp3   # macOS
  mpg123 sounds/attention.mp3   # Linux
  ```

### Generate a voice clip on macOS

The built-in `say` command turns text into spoken audio:

```bash
say -v Samantha "Claude is done" -o /tmp/done.aiff
afconvert /tmp/done.aiff ~/sounds/done.m4a -d aac -f m4af
```

Other fun voices to try: `Daniel`, `Karen`, `Moira`, `Alex`. Run
`say -v '?'` to list everything installed.
