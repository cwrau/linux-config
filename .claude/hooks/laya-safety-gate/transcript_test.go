package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func writeTranscript(t *testing.T, lines []string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "transcript.jsonl")
	if err := os.WriteFile(path, []byte(strings.Join(lines, "\n")+"\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestLastUserMessage_PicksPlainStringContent(t *testing.T) {
	path := writeTranscript(t, []string{
		`{"type":"user","message":{"role":"user","content":"first task"}}`,
		`{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"ok"}]}}`,
		`{"type":"user","message":{"role":"user","content":"second, real task"}}`,
	})
	got := LastUserMessage(path)
	if got != "second, real task" {
		t.Fatalf("got %q", got)
	}
}

func TestLastUserMessage_SkipsToolResultArrayContent(t *testing.T) {
	path := writeTranscript(t, []string{
		`{"type":"user","message":{"role":"user","content":"the real task"}}`,
		`{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"x"}]}}`,
		`{"type":"user","message":{"role":"user","content":[{"tool_use_id":"x","type":"tool_result","content":"some file contents"}]}}`,
	})
	got := LastUserMessage(path)
	if got != "the real task" {
		t.Fatalf("expected to skip the tool_result turn and find the real task, got %q", got)
	}
}

func TestLastUserMessage_MissingFileReturnsEmpty(t *testing.T) {
	got := LastUserMessage(filepath.Join(t.TempDir(), "does-not-exist.jsonl"))
	if got != "" {
		t.Fatalf("expected empty string for missing transcript, got %q", got)
	}
}
