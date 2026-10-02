package main

import "fmt"

// Decide maps a laya Verdict to a permission decision + human-readable
// reason, per the spec's "Decision policy" section. It is pure and has no
// knowledge of laya, HTTP, or the allowlist -- every branch is a direct
// threshold comparison, fully covered by table-driven unit tests.
func Decide(v Verdict, th Thresholds) (decision string, reason string) {
	if v.Irreversible < th.AllowMaxIrreversible &&
		v.Mutates < th.AllowMaxMutates &&
		v.OffTask < th.AllowMaxOffTask {
		return DecisionAllow, fmt.Sprintf(
			"irreversible=%.2f mutates=%.2f off_task=%.2f all below allow thresholds",
			v.Irreversible, v.Mutates, v.OffTask)
	}

	if v.Irreversible > th.DenyMinIrreversible {
		return DecisionDeny, fmt.Sprintf("irreversible=%.2f above deny threshold %.2f",
			v.Irreversible, th.DenyMinIrreversible)
	}
	if v.Mutates > th.DenyMinMutatesAndOffTask && v.OffTask > th.DenyMinMutatesAndOffTask {
		return DecisionDeny, fmt.Sprintf(
			"mutates=%.2f and off_task=%.2f both above deny threshold %.2f",
			v.Mutates, v.OffTask, th.DenyMinMutatesAndOffTask)
	}

	return DecisionAsk, fmt.Sprintf(
		"irreversible=%.2f mutates=%.2f off_task=%.2f in the ask range",
		v.Irreversible, v.Mutates, v.OffTask)
}

// FailureDecision is what main.go uses whenever QueryLaya (or anything
// else in the pipeline) errors -- always "ask", never allow or deny, per
// the spec's explicit fail-to-ask requirement.
func FailureDecision(reason string) (decision string, decisionReason string) {
	return DecisionAsk, reason
}
