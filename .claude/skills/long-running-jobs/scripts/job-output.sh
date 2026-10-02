#!/usr/bin/env bash
# Show the real output/result data a job wrote to its JOB_DIR (as opposed to
# journal logs -- see job-status.sh for those). By <identifier>, same
# derivation as start-job.sh, so you never need to re-parse $AOE_ARTIFACT_DIR
# or reconstruct the job-dir path by hand.
#
# Usage:
#   job-output.sh <identifier>          list the job dir contents
#   job-output.sh <identifier> <file>   print that file (path relative to the job dir)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$script_dir/_lib.sh"

id="${1:?usage: job-output.sh <identifier> [file]}"
jdir=$(job_dir "$id")

if [ ! -d "$jdir" ]; then
  echo "No job dir for identifier '$id': $jdir" >&2
  exit 1
fi

if [ "$#" -ge 2 ]; then
  file="$jdir/$2"
  if [ ! -f "$file" ]; then
    echo "No such file: $file" >&2
    exit 1
  fi
  cat "$file"
else
  ls -la "$jdir"
fi
