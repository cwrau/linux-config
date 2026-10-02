package main

import "testing"

func TestDecide_SilentAllowBelowAllThresholds(t *testing.T) {
	th := DefaultConfig().Thresholds
	d, _ := Decide(Verdict{Irreversible: 0.01, Mutates: 0.01, OffTask: 0.01, Scope: "file"}, th)
	if d != DecisionAllow {
		t.Fatalf("got %s", d)
	}
}

func TestDecide_AllowThresholdIsExclusive(t *testing.T) {
	th := DefaultConfig().Thresholds
	// Exactly at the allow threshold must NOT silent-allow (spec uses "<", not "<=").
	d, _ := Decide(Verdict{Irreversible: 0.05, Mutates: 0.01, OffTask: 0.01, Scope: "file"}, th)
	if d == DecisionAllow {
		t.Fatal("0.05 irreversible must not silent-allow at the exact threshold")
	}
}

func TestDecide_DenyOnHighIrreversible(t *testing.T) {
	th := DefaultConfig().Thresholds
	th.DenyMinIrreversible = 0.7 // rule is off by default; verify the mechanism still works when enabled
	d, _ := Decide(Verdict{Irreversible: 0.9, Mutates: 0.1, OffTask: 0.1, Scope: "system"}, th)
	if d != DecisionDeny {
		t.Fatalf("got %s", d)
	}
}

func TestDecide_DenyOnMutatesAndOffTaskBothHigh(t *testing.T) {
	th := DefaultConfig().Thresholds
	d, _ := Decide(Verdict{Irreversible: 0.1, Mutates: 0.9, OffTask: 0.9, Scope: "repo"}, th)
	if d != DecisionDeny {
		t.Fatalf("got %s", d)
	}
}

func TestDecide_NoDenyWhenOnlyMutatesHigh(t *testing.T) {
	th := DefaultConfig().Thresholds
	// mutates alone above threshold, off_task low -- must NOT deny (spec requires BOTH).
	d, _ := Decide(Verdict{Irreversible: 0.1, Mutates: 0.9, OffTask: 0.1, Scope: "repo"}, th)
	if d == DecisionDeny {
		t.Fatal("must not deny on mutates alone without off_task also high")
	}
}

func TestDecide_MiddleGroundIsAsk(t *testing.T) {
	th := DefaultConfig().Thresholds
	d, _ := Decide(Verdict{Irreversible: 0.3, Mutates: 0.3, OffTask: 0.3, Scope: "repo"}, th)
	if d != DecisionAsk {
		t.Fatalf("got %s", d)
	}
}

func TestFailureDecision_IsAlwaysAsk(t *testing.T) {
	d, reason := FailureDecision("laya-serve unreachable")
	if d != DecisionAsk || reason != "laya-serve unreachable" {
		t.Fatalf("got %s / %s", d, reason)
	}
}

func TestDecide_DefaultsNeverDenyOnIrreversibleAlone(t *testing.T) {
	th := DefaultConfig().Thresholds
	// Real traffic scored benign cargo test / doc writes at 0.74-0.81 and
	// rm -rf at 0.06, so irreversible alone must not deny by default.
	d, _ := Decide(Verdict{Irreversible: 0.99, Mutates: 0.2, OffTask: 0.1, Scope: "repo"}, th)
	if d == DecisionDeny {
		t.Fatal("default thresholds must not deny on irreversible alone")
	}
}
