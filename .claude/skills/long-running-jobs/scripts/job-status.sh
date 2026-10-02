#!/usr/bin/env bash
# Check on (or stop) a job started by start-job.sh, by <identifier> --
# reconstructs the unit name the same way start-job.sh derived it, so you
# never need to re-parse $AOE_ARTIFACT_DIR by hand to check on a job later.
#
# Usage: job-status.sh <identifier> [-n LINES | --full] [--stop]
#   -n LINES   journal lines to show (default 50)
#   --full     show the whole journal for the latest invocation instead
#   --stop     stop the unit (systemctl --user stop) after showing status
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$script_dir/_lib.sh"

id="${1:?usage: job-status.sh <identifier> [-n LINES | --full] [--stop]}"
shift

lines=50
full=0
do_stop=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n) lines="${2:?-n needs a line count}"; shift 2 ;;
    --full) full=1; shift ;;
    --stop) do_stop=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

unit=$(job_unit "$id")

echo "== $unit =="
state=$(systemctl --user is-active "$unit" 2>&1) || true
echo "state: $state"

echo
if [ "$full" -eq 1 ]; then
  journalctl --user -u "$unit" -I --no-pager -o cat
else
  journalctl --user -u "$unit" -I --no-pager -o cat | tail -n "$lines"
fi

if [ "$do_stop" -eq 1 ]; then
  echo
  echo "Stopping $unit..."
  systemctl --user stop "$unit"
fi
