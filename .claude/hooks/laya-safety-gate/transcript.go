package main

import (
	"bufio"
	"encoding/json"
	"os"
)

// transcriptTailBytes bounds how much of a (potentially very large) JSONL
// transcript this reads -- a full-file read is explicitly disallowed by
// the spec for long sessions.
const transcriptTailBytes = 65536

type transcriptEntry struct {
	Type    string `json:"type"`
	Message struct {
		Role    string          `json:"role"`
		Content json.RawMessage `json:"content"`
	} `json:"message"`
}

// LastUserMessage tail-reads transcriptPath and returns the most recent
// real human-typed message. Claude Code's transcript JSONL uses
// `"type":"user"` for two different things: an actual typed prompt
// (message.content is a JSON string) and a tool-result turn fed back to
// the model (message.content is a JSON array of content blocks) -- only
// the string-content form is a real task statement, so array-content
// entries are skipped rather than mistaken for the task.
//
// Returns "" (never an error) if the file is missing, unreadable, or no
// matching entry is found in the tail window -- a brand-new session with
// no transcript yet must not crash the hook.
func LastUserMessage(transcriptPath string) string {
	f, err := os.Open(transcriptPath)
	if err != nil {
		return ""
	}
	defer f.Close()

	info, err := f.Stat()
	if err != nil {
		return ""
	}
	start := int64(0)
	if info.Size() > transcriptTailBytes {
		start = info.Size() - transcriptTailBytes
	}
	if _, err := f.Seek(start, 0); err != nil {
		return ""
	}

	scanner := bufio.NewScanner(f)
	scanner.Buffer(make([]byte, 0, 1024*1024), 1024*1024)
	var lines []string
	first := true
	for scanner.Scan() {
		if first && start > 0 {
			// The seek almost certainly landed mid-line; that partial
			// first line can't be parsed as JSON, so drop it.
			first = false
			continue
		}
		first = false
		lines = append(lines, scanner.Text())
	}

	for i := len(lines) - 1; i >= 0; i-- {
		var entry transcriptEntry
		if err := json.Unmarshal([]byte(lines[i]), &entry); err != nil {
			continue
		}
		if entry.Type != "user" || entry.Message.Role != "user" {
			continue
		}
		var text string
		if err := json.Unmarshal(entry.Message.Content, &text); err != nil {
			continue // array content (tool_result), not a real prompt
		}
		return text
	}
	return ""
}
