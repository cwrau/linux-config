#!/usr/bin/env bash
# Start a command as a durable systemd --user unit per the long-running-jobs
# skill: named agent-<aoe-session-id>-<identifier>, in agent.slice, with a
# per-job JOB_DIR, and a completion notification back to this same AoE
# session wired up via notify-on-completion.sh (ExecStopPost, fires on
# success/failure/kill alike).
#
# Usage: start-job.sh <identifier> <command...>
#   e.g. start-job.sh helm-lint-all bash -c 'go-task lint-all > "$JOB_DIR/result.txt"'
#
# Extra env vars to forward to the job (beyond PATH/JOB_DIR/AOE_ARTIFACT_DIR,
# always forwarded): set AGENT_JOB_EXTRA_ENV to a space-separated list of
# names, e.g. AGENT_JOB_EXTRA_ENV="KUBECONFIG GOTOOLCHAIN" start-job.sh ...
#
# See job-status.sh, job-output.sh, list-jobs.sh for following up afterward.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$script_dir/_lib.sh"

id="${1:?usage: start-job.sh <identifier> <command...>}"
shift
[ "$#" -gt 0 ] || { echo "usage: start-job.sh <identifier> <command...>" >&2; exit 1; }

unit=$(job_unit "$id")
jdir=$(job_dir "$id")
mkdir -p "$jdir"

extra_env_args=()
for name in ${AGENT_JOB_EXTRA_ENV:-}; do
  extra_env_args+=(-E "$name")
done

systemd-run --user --collect --slice=agent --unit="$unit" --same-dir \
  -E PATH -E JOB_DIR="$jdir" -E AOE_ARTIFACT_DIR "${extra_env_args[@]}" \
  --property="ExecStopPost=bash $script_dir/notify-on-completion.sh $unit" \
  "$@"

echo "Started $unit -- job dir: $jdir"
