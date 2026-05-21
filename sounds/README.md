# Sounds

Three short bell samples played by Claude Code hooks.

| File | When it plays | Character |
|---|---|---|
| `attention.wav`  | `Notification` event       | Single bright bell (~3.2 kHz, ~400 ms) |
| `permission.wav` | `PermissionRequest` event  | Single lower bell (~2.6 kHz, ~450 ms) |
| `done.wav`       | `Stop` event               | Two bells, ding-ding (~950 ms) |

All three are 44.1 kHz mono 16-bit PCM WAVs, synthesized from a sum of
decaying sinusoids (fundamental + harmonic + inharmonic partials) for
that metallic hotel-counter-bell timbre.

---

## Swap your own sounds

Drop a `.wav` of the same name into `~/.claude/bell/sounds/` after
installing — the installer won't overwrite existing files on re-run.

```bash
cp my-chime.wav ~/.claude/bell/sounds/attention.wav
```

### Tips

- **Keep single chimes under ~500 ms.** Anything longer overlaps your
  next prompt and feels laggy.
- **WAV, 16-bit, 44.1 kHz, mono** is the most portable format —
  `afplay`, `paplay`, `aplay`, and `pw-play` all play it without
  conversion.
- **Free sources for bells, chimes, and dings:**
  [Freesound.org](https://freesound.org),
  [Mixkit](https://mixkit.co/free-sound-effects/bell/),
  [SampleFocus](https://samplefocus.com).
- **Test a file** before committing to it:

  ```bash
  afplay ~/.claude/bell/sounds/attention.wav   # macOS
  paplay ~/.claude/bell/sounds/attention.wav   # Linux (PulseAudio)
  ```

### Generate a voice clip on macOS

The built-in `say` command turns text into spoken audio. Pipe it
through `afconvert` to get a hook-compatible WAV:

```bash
say -v Samantha "Claude is done" -o /tmp/done.aiff && \
  afconvert /tmp/done.aiff ~/.claude/bell/sounds/done.wav -d LEI16
```

Other fun voices to try: `Daniel`, `Karen`, `Moira`, `Alex`. Run
`say -v '?'` to list everything installed.

### Regenerate the bundled bells

If you ever want to tweak the synthesized originals (different pitch,
harder strike, slower decay), edit `generate_sounds.py` at the repo
root and run:

```bash
python3 generate_sounds.py
```

It only depends on `numpy` and the Python stdlib `wave` module.
