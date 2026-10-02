# Sourced by the other long-running-jobs scripts. Derives the unit name and
# job dir from an <identifier> the same way, once, so no script (or the
# agent, inline) has to re-parse $AOE_ARTIFACT_DIR by hand.

aoe_session_id() {
  basename "${AOE_ARTIFACT_DIR:-noaoe}"
}

job_unit() {
  echo "agent-$(aoe_session_id)-$1"
}

job_dir() {
  echo "${XDG_STATE_HOME:-$HOME/.local/state}/agent-jobs/$(aoe_session_id)/$1"
}
