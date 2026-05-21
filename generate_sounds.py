#!/usr/bin/env python3
"""
Generate hotel desk bell sounds for claude-bell.

Synthesizes metallic bell sounds using a sum of decaying sinusoids:
fundamental + harmonic partials + inharmonic partials. This produces
the bright, shimmering "ting" of a real hotel counter bell.

Outputs three WAV files into ./sounds/:
  - attention.wav   : single bell, ~3200 Hz, ~400 ms
  - done.wav        : two bells (ding-ding), ~3200 then ~3400 Hz, ~950 ms total
  - permission.wav  : single bell, lower ~2600 Hz, ~450 ms

All files: 44100 Hz mono, 16-bit PCM, normalized to 0.85 peak.
"""

import os
import wave
import struct
import numpy as np

SAMPLE_RATE = 44100
PEAK = 0.85


def bell(fundamental_hz: float, duration_s: float, decay: float = 8.0) -> np.ndarray:
    """Synthesize a single bell hit.

    Sums a fundamental sinusoid with harmonic (2x, 3x) and inharmonic
    (~4.7x, ~6.3x) partials, each with its own exponential decay. The
    inharmonic partials give the metallic shimmer characteristic of
    struck-metal bells.
    """
    n = int(SAMPLE_RATE * duration_s)
    t = np.linspace(0, duration_s, n, endpoint=False)

    partials = [
        (1.00, 1.00, decay * 1.0),
        (2.00, 0.55, decay * 1.4),
        (3.00, 0.30, decay * 1.8),
        (4.70, 0.45, decay * 1.2),
        (6.30, 0.25, decay * 1.6),
        (8.10, 0.12, decay * 2.0),
    ]

    wave_out = np.zeros(n, dtype=np.float64)
    for ratio, amp, d in partials:
        freq = fundamental_hz * ratio
        envelope = np.exp(-d * t)
        wave_out += amp * envelope * np.sin(2 * np.pi * freq * t)

    # 2 ms attack ramp to avoid click on transient
    attack_samples = int(SAMPLE_RATE * 0.002)
    if attack_samples > 0:
        ramp = np.linspace(0.0, 1.0, attack_samples)
        wave_out[:attack_samples] *= ramp

    return wave_out


def normalize(samples: np.ndarray, peak: float = PEAK) -> np.ndarray:
    max_abs = float(np.max(np.abs(samples)))
    if max_abs == 0:
        return samples
    return samples * (peak / max_abs)


def write_wav(path: str, samples: np.ndarray) -> None:
    samples = normalize(samples)
    pcm = np.clip(samples, -1.0, 1.0)
    pcm_int = (pcm * 32767.0).astype(np.int16)

    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(pcm_int.tobytes())


def attention_sound() -> np.ndarray:
    # Single crisp bell, ~3200 Hz, 400 ms, fast decay
    return bell(fundamental_hz=3200.0, duration_s=0.400, decay=9.0)


def done_sound() -> np.ndarray:
    # Two bells with a 250 ms silent gap, second slightly higher
    gap_samples = int(SAMPLE_RATE * 0.250)
    first = bell(fundamental_hz=3200.0, duration_s=0.350, decay=10.0)
    second = bell(fundamental_hz=3400.0, duration_s=0.350, decay=10.0)
    silence = np.zeros(gap_samples, dtype=np.float64)
    return np.concatenate([first, silence, second])


def permission_sound() -> np.ndarray:
    # Lower, more authoritative bell, ~2600 Hz, 450 ms, slower decay
    return bell(fundamental_hz=2600.0, duration_s=0.450, decay=6.5)


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(here, "sounds")
    os.makedirs(out_dir, exist_ok=True)

    write_wav(os.path.join(out_dir, "attention.wav"), attention_sound())
    write_wav(os.path.join(out_dir, "done.wav"), done_sound())
    write_wav(os.path.join(out_dir, "permission.wav"), permission_sound())

    for name in ("attention.wav", "done.wav", "permission.wav"):
        path = os.path.join(out_dir, name)
        size_kb = os.path.getsize(path) / 1024.0
        print(f"  wrote {name:18s}  {size_kb:6.1f} KB")


if __name__ == "__main__":
    main()
