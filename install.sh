#!/usr/bin/env bash
# claude-bell installer.
# Copies the player + sounds to ~/.claude/bell/ and merges hook config
# into ~/.claude/settings.json. Safe to re-run: user-customized sounds
# are preserved, and existing settings.json keys are merged, not replaced.

set -euo pipefail

# --- colors ---------------------------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
  GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; CYAN=$'\033[36m'
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""
fi

say()  { printf "%s\n" "$*"; }
ok()   { printf "  ${GREEN}✓${RESET} %s\n" "$*"; }
info() { printf "  ${BLUE}•${RESET} %s\n" "$*"; }
warn() { printf "  ${YELLOW}!${RESET} %s\n" "$*"; }

# --- paths ----------------------------------------------------------------
src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest_dir="$HOME/.claude/bell"
sounds_dest="$dest_dir/sounds"
hooks_dest="$dest_dir/hooks"
settings_file="$HOME/.claude/settings.json"

# --- preflight ------------------------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  printf "${YELLOW}python3 is required for settings.json merging.${RESET}\n" >&2
  exit 1
fi

say ""
say "${BOLD}${CYAN}🔔 Installing claude-bell${RESET}"
say ""

# --- copy files -----------------------------------------------------------
mkdir -p "$hooks_dest" "$sounds_dest" "$HOME/.claude"

cp "$src_dir/hooks/play.sh" "$hooks_dest/play.sh"
chmod +x "$hooks_dest/play.sh"
ok "installed player → ${DIM}$hooks_dest/play.sh${RESET}"

for sound in attention.wav done.wav permission.wav; do
  if [[ -f "$sounds_dest/$sound" ]]; then
    info "kept existing ${DIM}$sounds_dest/$sound${RESET}"
  else
    cp "$src_dir/sounds/$sound" "$sounds_dest/$sound"
    ok "installed sound  → ${DIM}$sounds_dest/$sound${RESET}"
  fi
done

# --- merge settings.json --------------------------------------------------
[[ -f "$settings_file" ]] || echo "{}" > "$settings_file"

PLAY_CMD='bash "$HOME/.claude/bell/hooks/play.sh"'
PERMISSION_ENTRY='Bash(bash "$HOME/.claude/bell/hooks/play.sh" *)'

SETTINGS_FILE="$settings_file" PLAY_CMD="$PLAY_CMD" PERMISSION_ENTRY="$PERMISSION_ENTRY" python3 <<'PY'
import json
import os
import sys

path = os.environ["SETTINGS_FILE"]
play = os.environ["PLAY_CMD"]
perm = os.environ["PERMISSION_ENTRY"]

try:
    with open(path, "r", encoding="utf-8") as f:
        text = f.read().strip() or "{}"
    data = json.loads(text)
    if not isinstance(data, dict):
        raise ValueError("settings.json must be a JSON object at the top level")
except FileNotFoundError:
    data = {}
except json.JSONDecodeError as e:
    print(f"ERROR: {path} is not valid JSON: {e}", file=sys.stderr)
    sys.exit(1)

event_to_sound = {
    "Stop":              "done.wav",
    "Notification":      "attention.wav",
    "PermissionRequest": "permission.wav",
}

hooks = data.setdefault("hooks", {})
if not isinstance(hooks, dict):
    print("ERROR: settings.json 'hooks' must be an object", file=sys.stderr)
    sys.exit(1)

def group_has_bell(group):
    if not isinstance(group, dict):
        return False
    inner = group.get("hooks", [])
    if not isinstance(inner, list):
        return False
    return any(isinstance(h, dict) and "bell" in str(h.get("command", "")) for h in inner)

for event, sound in event_to_sound.items():
    cmd = f'{play} "$HOME/.claude/bell/sounds/{sound}"'
    new_group = {"hooks": [{"type": "command", "command": cmd}]}
    existing = hooks.get(event)
    if isinstance(existing, list):
        # Drop any prior claude-bell groups, keep everything else.
        kept = [g for g in existing if not group_has_bell(g)]
        kept.append(new_group)
        hooks[event] = kept
    else:
        hooks[event] = [new_group]

permissions = data.setdefault("permissions", {})
if not isinstance(permissions, dict):
    print("ERROR: settings.json 'permissions' must be an object", file=sys.stderr)
    sys.exit(1)
allow = permissions.setdefault("allow", [])
if not isinstance(allow, list):
    print("ERROR: settings.json 'permissions.allow' must be a list", file=sys.stderr)
    sys.exit(1)
if perm not in allow:
    allow.append(perm)

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

ok "merged hooks + permissions into ${DIM}$settings_file${RESET}"

# --- summary --------------------------------------------------------------
say ""
say "${BOLD}Event map${RESET}"
printf "  ${CYAN}%-18s${RESET}  ${DIM}→${RESET}  %s\n" "attention.wav"  "Notification        (1 bell — Claude needs your attention)"
printf "  ${CYAN}%-18s${RESET}  ${DIM}→${RESET}  %s\n" "permission.wav" "PermissionRequest   (1 bell — Claude wants approval)"
printf "  ${CYAN}%-18s${RESET}  ${DIM}→${RESET}  %s\n" "done.wav"       "Stop                (2 bells — Claude is done)"
say ""
say "${BOLD}${GREEN}✓ Installed.${RESET} Restart Claude Code to activate."
say ""
