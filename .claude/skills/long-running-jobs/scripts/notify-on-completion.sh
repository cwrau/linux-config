#!/usr/bin/env bash
# ExecStopPost target for a long-running-jobs unit. Reads AOE_ARTIFACT_DIR
# from the environment (forward it to the unit with `-E AOE_ARTIFACT_DIR` --
# bare, no `=value`, just copies the launching shell's current value) instead
# of requiring the caller to derive/bake the session id in themselves.
#
# systemd sets SERVICE_RESULT / EXIT_CODE / EXIT_STATUS for ExecStopPost
# automatically -- no need to pass those in.
#
# Usage: notify-on-completion.sh <unit-name>
set -euo pipefail

unit="${1:?usage: notify-on-completion.sh <unit-name>}"
sid=$(basename "${AOE_ARTIFACT_DIR:?AOE_ARTIFACT_DIR not set -- forward it to the unit with -E AOE_ARTIFACT_DIR}")
log="${JOB_DIR:-/tmp}/notify.log"

aoe send "$sid" \
  "Job $unit finished: ${SERVICE_RESULT:-unknown} (exit ${EXIT_STATUS:-?}). Output in ${JOB_DIR:-<unknown>}." \
  > "$log" 2>&1
