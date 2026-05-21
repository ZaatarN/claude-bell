#!/usr/bin/env bash
# claude-bell uninstaller.
# Removes claude-bell hooks + permission from settings.json (leaving any
# other hooks/permissions intact) and deletes ~/.claude/bell/.

set -euo pipefail

if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
  GREEN=$'\033[32m'; YELLOW=$'\033[33m'; CYAN=$'\033[36m'
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; YELLOW=""; CYAN=""
fi

say()  { printf "%s\n" "$*"; }
ok()   { printf "  ${GREEN}✓${RESET} %s\n" "$*"; }
warn() { printf "  ${YELLOW}!${RESET} %s\n" "$*"; }

bell_dir="$HOME/.claude/bell"
settings_file="$HOME/.claude/settings.json"

say ""
say "${BOLD}${CYAN}🔕 Uninstalling claude-bell${RESET}"
say ""

if [[ -f "$settings_file" ]]; then
  if ! command -v python3 >/dev/null 2>&1; then
    warn "python3 not found — settings.json was not modified."
  else
    SETTINGS_FILE="$settings_file" python3 <<'PY'
import json
import os
import sys

path = os.environ["SETTINGS_FILE"]
try:
    with open(path, "r", encoding="utf-8") as f:
        text = f.read().strip() or "{}"
    data = json.loads(text)
except (FileNotFoundError, json.JSONDecodeError):
    sys.exit(0)

def is_bell_hook(h):
    return isinstance(h, dict) and "bell" in str(h.get("command", ""))

def strip_bell_from_group(group):
    if not isinstance(group, dict):
        return group, False
    inner = group.get("hooks", [])
    if not isinstance(inner, list):
        return group, False
    cleaned = [h for h in inner if not is_bell_hook(h)]
    if not cleaned:
        return None, True   # drop the whole group
    group["hooks"] = cleaned
    return group, len(cleaned) != len(inner)

hooks = data.get("hooks")
if isinstance(hooks, dict):
    for event in list(hooks.keys()):
        v = hooks[event]
        if isinstance(v, list):
            new_list = []
            for g in v:
                cleaned, _ = strip_bell_from_group(g)
                if cleaned is not None:
                    new_list.append(cleaned)
            if new_list:
                hooks[event] = new_list
            else:
                del hooks[event]
    if not hooks:
        data.pop("hooks", None)

permissions = data.get("permissions")
if isinstance(permissions, dict):
    allow = permissions.get("allow")
    if isinstance(allow, list):
        allow = [a for a in allow if not (isinstance(a, str) and "bell" in a)]
        if allow:
            permissions["allow"] = allow
        else:
            permissions.pop("allow", None)
    if not permissions:
        data.pop("permissions", None)

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
    ok "stripped bell entries from ${DIM}$settings_file${RESET}"
  fi
else
  warn "no settings.json found at $settings_file — nothing to clean."
fi

if [[ -d "$bell_dir" ]]; then
  rm -rf "$bell_dir"
  ok "removed ${DIM}$bell_dir${RESET}"
else
  warn "$bell_dir did not exist."
fi

say ""
say "${BOLD}${GREEN}✓ Uninstalled.${RESET} Restart Claude Code to clear the hooks."
say ""
