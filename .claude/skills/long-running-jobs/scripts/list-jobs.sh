#!/usr/bin/env bash
# List every long-running-jobs unit and job dir for this AoE session (or
# every session's units across the whole agent.slice, with --all-sessions).
#
# Usage: list-jobs.sh [--all-sessions]
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$script_dir/_lib.sh"

if [ "${1:-}" = "--all-sessions" ]; then
  echo "== units across all sessions (agent.slice) =="
  systemd-cgls --user-unit=agent.slice
  exit 0
fi

sid=$(aoe_session_id)

echo "== units for this session (agent-$sid-*) =="
systemctl --user list-units --all "agent-$sid-*"

echo
echo "== job dirs for this session =="
ls -la "${XDG_STATE_HOME:-$HOME/.local/state}/agent-jobs/$sid/" 2>/dev/null \
  || echo "(none yet: ${XDG_STATE_HOME:-$HOME/.local/state}/agent-jobs/$sid/)"
