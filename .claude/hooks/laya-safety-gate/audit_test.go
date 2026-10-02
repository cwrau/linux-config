package main

import (
	"encoding/json"
	"net"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"
)

// journalStub listens on a unixgram socket the way journald's native
// socket does, so tests can read back exactly what the hook sends.
type journalStub struct {
	conn net.PacketConn
	path string
}

func newJournalStub(t *testing.T) *journalStub {
	t.Helper()
	path := filepath.Join(t.TempDir(), "j")
	conn, err := net.ListenPacket("unixgram", path)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { conn.Close() })
	return &journalStub{conn: conn, path: path}
}

func (s *journalStub) datagrams() []string {
	var out []string
	buf := make([]byte, 65536)
	for {
		s.conn.SetReadDeadline(time.Now().Add(50 * time.Millisecond))
		n, _, err := s.conn.ReadFrom(buf)
		if err != nil {
			return out
		}
		out = append(out, string(buf[:n]))
	}
}

func journalFields(payload, name string) []string {
	var vals []string
	for _, line := range strings.Split(payload, "\n") {
		if strings.HasPrefix(line, name+"=") {
			vals = append(vals, strings.TrimPrefix(line, name+"="))
		}
	}
	return vals
}

func (s *journalStub) entries(t *testing.T) []AuditEntry {
	t.Helper()
	var entries []AuditEntry
	for _, d := range s.datagrams() {
		msgs := journalFields(d, "MESSAGE")
		if len(msgs) != 1 {
			t.Fatalf("expected exactly one MESSAGE field, got %d in %q", len(msgs), d)
		}
		var e AuditEntry
		if err := json.Unmarshal([]byte(msgs[0]), &e); err != nil {
			t.Fatalf("MESSAGE is not valid JSON: %v -- %q", err, msgs[0])
		}
		entries = append(entries, e)
	}
	return entries
}

func TestJournalPayload_HasMessageAndStructuredFields(t *testing.T) {
	p := string(journalPayload(AuditEntry{
		ToolName: "Bash", Action: DecisionAsk, Reason: "r",
		Verdict: &Verdict{Irreversible: 0.1},
	}))
	for field, want := range map[string]string{
		"SYSLOG_IDENTIFIER": "laya-safety-gate",
		"TOOL_NAME":         "Bash",
		"ACTION":            DecisionAsk,
		"PRIORITY":          "6",
	} {
		got := journalFields(p, field)
		if len(got) != 1 || got[0] != want {
			t.Fatalf("%s: want %q, got %v", field, want, got)
		}
	}
	if len(journalFields(p, "MESSAGE")) != 1 {
		t.Fatalf("missing MESSAGE in %q", p)
	}
}

func TestJournalPayload_LayaFailureIsWarningPriority(t *testing.T) {
	p := string(journalPayload(AuditEntry{ToolName: "Bash", Action: DecisionAsk, Reason: "laya-serve error: x"}))
	if got := journalFields(p, "PRIORITY"); len(got) != 1 || got[0] != "4" {
		t.Fatalf("a failure entry (no verdict) must be priority 4, got %v", got)
	}
}

func TestJournalPayload_NewlinesCannotInjectFields(t *testing.T) {
	p := string(journalPayload(AuditEntry{
		ToolName: "x\nPRIORITY=0\nSYSLOG_IDENTIFIER=evil",
		Action:   DecisionAsk,
		Reason:   "multi\nline\nPRIORITY=0",
		Input:    "{\"command\":\"a\\nb\"}\nPRIORITY=0",
	}))
	if got := journalFields(p, "PRIORITY"); len(got) != 1 {
		t.Fatalf("injected extra PRIORITY field: %v in %q", got, p)
	}
	if got := journalFields(p, "SYSLOG_IDENTIFIER"); len(got) != 1 || got[0] != "laya-safety-gate" {
		t.Fatalf("injected SYSLOG_IDENTIFIER: %v", got)
	}
}

func TestWriteAudit_DeliversEntryToSocket(t *testing.T) {
	stub := newJournalStub(t)
	if err := WriteAudit(stub.path, AuditEntry{ToolName: "Bash", Action: DecisionAsk, Reason: "test", LatencyMS: 10}); err != nil {
		t.Fatal(err)
	}
	entries := stub.entries(t)
	if len(entries) != 1 || entries[0].ToolName != "Bash" || entries[0].Action != DecisionAsk || entries[0].Timestamp == "" {
		t.Fatalf("got %+v", entries)
	}
}

func TestWriteAudit_ConcurrentWritesStayIntact(t *testing.T) {
	stub := newJournalStub(t)
	var wg sync.WaitGroup
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func(n int) {
			defer wg.Done()
			_ = WriteAudit(stub.path, AuditEntry{ToolName: "Bash", Action: DecisionAsk, Reason: "concurrent", LatencyMS: int64(n)})
		}(i)
	}
	wg.Wait()
	if got := len(stub.entries(t)); got != 20 {
		t.Fatalf("expected 20 intact entries, got %d", got)
	}
}

func TestWriteAudit_MissingSocketIsErrorNotPanic(t *testing.T) {
	err := WriteAudit(filepath.Join(t.TempDir(), "no-such-socket"), AuditEntry{ToolName: "Bash", Action: DecisionAsk})
	if err == nil {
		t.Fatal("expected an error when journald is unreachable")
	}
}

func TestJournalPayload_TruncatedVerdictIsFlaggedAndWarning(t *testing.T) {
	p := string(journalPayload(AuditEntry{
		ToolName: "Bash", Action: DecisionAsk,
		Verdict: &Verdict{Truncated: true, TokensDropped: 7},
	}))
	if got := journalFields(p, "LAYA_TRUNCATED"); len(got) != 1 || got[0] != "1" {
		t.Fatalf("expected LAYA_TRUNCATED=1, got %v", got)
	}
	if got := journalFields(p, "PRIORITY"); len(got) != 1 || got[0] != "4" {
		t.Fatalf("truncated verdict is unreliable, want priority 4, got %v", got)
	}
}

func TestJournalPayload_UntruncatedVerdictHasNoTruncatedField(t *testing.T) {
	p := string(journalPayload(AuditEntry{ToolName: "Bash", Action: DecisionAsk, Verdict: &Verdict{}}))
	if got := journalFields(p, "LAYA_TRUNCATED"); len(got) != 0 {
		t.Fatalf("unexpected LAYA_TRUNCATED field: %v", got)
	}
	if got := journalFields(p, "PRIORITY"); len(got) != 1 || got[0] != "6" {
		t.Fatalf("want priority 6, got %v", got)
	}
}
