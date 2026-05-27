#!/usr/bin/env python3
"""Cross-platform notification sound player for claude-bell.

Usage: play.py <path-to-sound-file>

Plays the given audio file in the background and exits immediately.
Always exits 0 — playback failures must never disrupt Claude Code.
"""

import os
import shutil
import subprocess
import sys


def main():
    if len(sys.argv) < 2:
        return

    sound_file = sys.argv[1]

    override_dir = os.environ.get("CLAUDE_BELL_SOUNDS_DIR")
    if override_dir:
        override_path = os.path.join(override_dir, os.path.basename(sound_file))
        if os.path.isfile(override_path):
            sound_file = override_path

    if not os.path.isfile(sound_file):
        return

    platform = sys.platform
    if platform == "darwin":
        _play_darwin(sound_file)
    elif platform == "win32":
        _play_windows(sound_file)
    else:
        _play_unix(sound_file)


def _play_darwin(path):
    _spawn_detached(["afplay", path])


def _play_unix(path):
    players = [
        ["mpg123", "-q"],
        ["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet"],
        ["mpv", "--really-quiet", "--no-video"],
        ["cvlc", "--play-and-exit", "--quiet"],
        ["paplay"],
        ["aplay"],
        ["pw-play"],
    ]
    for cmd in players:
        if shutil.which(cmd[0]):
            _spawn_detached(cmd + [path])
            return


def _play_windows(path):
    ps_script = (
        "Add-Type -AssemblyName presentationCore;"
        "$p = New-Object System.Windows.Media.MediaPlayer;"
        "$p.Open([uri]'" + path.replace("'", "''") + "');"
        "$p.Play();"
        "Start-Sleep -Seconds 5"
    )
    _spawn_detached([
        "powershell", "-NoProfile", "-NonInteractive",
        "-WindowStyle", "Hidden", "-Command", ps_script,
    ])


def _spawn_detached(cmd):
    kwargs = {
        "stdout": subprocess.DEVNULL,
        "stderr": subprocess.DEVNULL,
    }
    if sys.platform == "win32":
        # CREATE_NO_WINDOW hides the console but keeps audio session access.
        # DETACHED_PROCESS would lose the audio session entirely.
        kwargs["creationflags"] = subprocess.CREATE_NO_WINDOW
    else:
        kwargs["start_new_session"] = True
    subprocess.Popen(cmd, **kwargs)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
