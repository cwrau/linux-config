package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRun_UnparseableInputEmitsAsk(t *testing.T) {
	in := strings.NewReader("not json")
	var out bytes.Buffer
	run(in, &out)
	if !strings.Contains(out.String(), `"permissionDecision":"ask"`) {
		t.Fatalf("expected ask decision, got %s", out.String())
	}
}

func TestRecoverToAsk_CatchesPanic(t *testing.T) {
	var out bytes.Buffer
	func() {
		defer recoverToAsk(&out)
		panic("boom")
	}()
	if !strings.Contains(out.String(), `"permissionDecision":"ask"`) {
		t.Fatalf("expected ask decision after panic, got %s", out.String())
	}
}

func TestBuildState_TruncatesOversizedToolInput(t *testing.T) {
	huge := strings.Repeat("a", 5000)
	raw, _ := json.Marshal(map[string]string{"content": huge})
	state := buildState("some task", "Write", raw)
	if len(state) > maxToolInputChars+200 { // task + tool name + markers, generous bound
		t.Fatalf("state not truncated, len=%d", len(state))
	}
	if !strings.Contains(state, "...(truncated)") {
		t.Fatal("expected truncation marker")
	}
}

func TestBuildState_ShortInputUntouched(t *testing.T) {
	raw, _ := json.Marshal(map[string]string{"command": "ls"})
	state := buildState("task", "Bash", raw)
	if strings.Contains(state, "(truncated)") {
		t.Fatal("short input must not be marked truncated")
	}
	if !strings.Contains(state, `"command":"ls"`) {
		t.Fatalf("expected tool_input present verbatim, got %s", state)
	}
}

func newLayaStub(t *testing.T, irreversible, mutates, offTask float64) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]any{
			"answers": map[string]any{
				"irreversible": map[string]any{"noul": irreversible},
				"mutates":      map[string]any{"noul": mutates},
				"off_task":     map[string]any{"noul": offTask},
				"scope":        map[string]any{"choice": "repo"},
			},
		})
	}))
	t.Cleanup(srv.Close)
	return srv
}

var lastJournal *journalStub

func setupHome(t *testing.T, mode, layaURL string) string {
	t.Helper()
	lastJournal = newJournalStub(t)
	prev := auditSocketPath
	auditSocketPath = lastJournal.path
	t.Cleanup(func() { auditSocketPath = prev })
	home := t.TempDir()
	dir := filepath.Join(home, ".claude", "hooks")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	cfg := DefaultConfig()
	cfg.Mode = mode
	cfg.LayaURL = layaURL
	data, _ := json.Marshal(cfg)
	if err := os.WriteFile(filepath.Join(dir, "laya-safety-config.json"), data, 0o644); err != nil {
		t.Fatal(err)
	}
	return home
}

func readAudit(t *testing.T, home string) []AuditEntry {
	t.Helper()
	return lastJournal.entries(t)
}

const bashInput = `{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/x"},"transcript_path":"/nonexistent"}`

func TestRunWith_LogOnlyEmitsNothingButLogs(t *testing.T) {
	srv := newLayaStub(t, 0.9, 0.9, 0.9) // would be a deny when enforcing
	home := setupHome(t, "log-only", srv.URL)
	var out bytes.Buffer
	runWith(strings.NewReader(bashInput), &out, home)
	if out.Len() != 0 {
		t.Fatalf("log-only must print nothing, got %s", out.String())
	}
	entries := readAudit(t, home)
	if len(entries) != 1 || entries[0].Verdict == nil || entries[0].Verdict.Irreversible != 0.9 {
		t.Fatalf("expected one logged verdict, got %+v", entries)
	}
}

func TestRunWith_LogOnlyFailureEmitsNothingButLogs(t *testing.T) {
	home := setupHome(t, "log-only", "http://127.0.0.1:1")
	var out bytes.Buffer
	runWith(strings.NewReader(bashInput), &out, home)
	if out.Len() != 0 {
		t.Fatalf("log-only must print nothing even on laya failure, got %s", out.String())
	}
	entries := readAudit(t, home)
	if len(entries) != 1 || entries[0].Verdict != nil || !strings.Contains(entries[0].Reason, "laya-serve error") {
		t.Fatalf("expected one logged failure, got %+v", entries)
	}
}

func TestRunWith_EnforceEmitsDecision(t *testing.T) {
	srv := newLayaStub(t, 0.9, 0.9, 0.9)
	home := setupHome(t, "enforce", srv.URL)
	var out bytes.Buffer
	runWith(strings.NewReader(bashInput), &out, home)
	if !strings.Contains(out.String(), `"permissionDecision":"deny"`) {
		t.Fatalf("expected deny, got %s", out.String())
	}
}

func TestRunWith_UnknownModeEnforces(t *testing.T) {
	home := setupHome(t, "typo-mode", "http://127.0.0.1:1")
	var out bytes.Buffer
	runWith(strings.NewReader(bashInput), &out, home)
	if !strings.Contains(out.String(), `"permissionDecision":"ask"`) {
		t.Fatalf("unknown mode must enforce (fail to ask), got %q", out.String())
	}
}

func TestRunWith_AuditRecordsTruncatedInput(t *testing.T) {
	srv := newLayaStub(t, 0.1, 0.1, 0.1)
	home := setupHome(t, "log-only", srv.URL)
	long := strings.Repeat("a", 1000)
	in := `{"tool_name":"Write","tool_input":{"content":"` + long + `"},"transcript_path":"/nonexistent"}`
	runWith(strings.NewReader(in), &bytes.Buffer{}, home)
	entries := readAudit(t, home)
	if len(entries) != 1 {
		t.Fatalf("got %+v", entries)
	}
	got := entries[0].Input
	if got == "" || len(got) > maxAuditInputChars+20 || !strings.Contains(got, "...(truncated)") {
		t.Fatalf("expected truncated input, len=%d: %q", len(got), got)
	}
}

func TestRunWith_AuditRecordsShortInputVerbatim(t *testing.T) {
	srv := newLayaStub(t, 0.1, 0.1, 0.1)
	home := setupHome(t, "log-only", srv.URL)
	runWith(strings.NewReader(bashInput), &bytes.Buffer{}, home)
	entries := readAudit(t, home)
	if !strings.Contains(entries[0].Input, `"command":"rm -rf /tmp/x"`) {
		t.Fatalf("expected command in audit input, got %q", entries[0].Input)
	}
}

func TestBuildState_CommandPrecedesTask(t *testing.T) {
	raw, _ := json.Marshal(map[string]string{"command": "rm -rf /tmp/x"})
	state := buildState("clean up", "Bash", raw)
	// laya drops tokens from the END when the state is too long, so the
	// action under judgement must come before the (long) task text.
	if strings.Index(state, "rm -rf") > strings.Index(state, "Task:") {
		t.Fatalf("command must precede task, got %q", state)
	}
}

func TestBuildState_LongTaskIsCappedAndCommandSurvives(t *testing.T) {
	task := strings.Repeat("Review the following change carefully. ", 200) // ~7.8k chars
	raw, _ := json.Marshal(map[string]string{"command": "rm -rf /home/cwr"})
	state := buildState(task, "Bash", raw)
	if len(state) > maxTaskChars+300 {
		t.Fatalf("task not capped, state len=%d", len(state))
	}
	if !strings.Contains(state, "rm -rf /home/cwr") {
		t.Fatalf("command lost from state: %q", state)
	}
	if !strings.Contains(state, "...(truncated)") {
		t.Fatal("expected truncation marker on the task")
	}
}

func TestRunWith_AuditRecordsTruncation(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]any{
			"answers": map[string]any{
				"irreversible": map[string]any{"noul": 0.1},
				"mutates":      map[string]any{"noul": 0.1},
				"off_task":     map[string]any{"noul": 0.1},
				"scope":        map[string]any{"choice": "repo"},
			},
			"usage": map[string]any{"truncated": true, "state_tokens_dropped": 99},
		})
	}))
	defer srv.Close()
	home := setupHome(t, "log-only", srv.URL)
	runWith(strings.NewReader(bashInput), &bytes.Buffer{}, home)
	entries := readAudit(t, home)
	if len(entries) != 1 || entries[0].Verdict == nil || !entries[0].Verdict.Truncated || entries[0].Verdict.TokensDropped != 99 {
		t.Fatalf("expected truncation recorded in the audit verdict, got %+v", entries)
	}
}

func TestRunWith_AuditRecordsSignalsAndTruncatedQuestions(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		a := coreAnswers()
		a["damage"] = map[string]any{"probabilities": map[string]any{"none": 0.5, "small": 0.2, "large": 0.2, "severe": 0.1}}
		json.NewEncoder(w).Encode(map[string]any{"answers": a, "usage": map[string]any{"truncated_questions": []string{"off_task_v2"}}})
	}))
	defer srv.Close()
	home := setupHome(t, "log-only", srv.URL)
	runWith(strings.NewReader(bashInput), &bytes.Buffer{}, home)
	entries := readAudit(t, home)
	if len(entries) != 1 || entries[0].Verdict == nil {
		t.Fatalf("got %+v", entries)
	}
	v := entries[0].Verdict
	if v.Signals["damage"] < 0.299 || v.Signals["damage"] > 0.301 || len(v.TruncatedQuestions) != 1 {
		t.Fatalf("signals/truncated questions not in audit verdict: %+v", v)
	}
}
