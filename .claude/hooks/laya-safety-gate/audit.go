package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net"
	"strings"
	"time"
)

const journalSocketPath = "/run/systemd/journal/socket"

// auditSocketPath is a variable only so tests can point it at a stub.
var auditSocketPath = journalSocketPath

// oneLine keeps a value on a single line: in journald's native protocol a
// newline inside a plain "NAME=value" field would start a new field.
func oneLine(s string) string {
	return strings.NewReplacer("\n", " ", "\r", " ").Replace(s)
}

// journalPayload renders an entry in journald's native datagram format. MESSAGE
// is the entry as JSON (json.Marshal escapes newlines, so it stays one line);
// the other fields make `journalctl TOOL_NAME=Bash ACTION=ask` work.
func journalPayload(e AuditEntry) []byte {
	msg, _ := json.Marshal(e)
	priority := "6" // info
	truncated := e.Verdict != nil && e.Verdict.Truncated
	if e.Verdict == nil || truncated {
		priority = "4" // warning: no verdict, or one judged on a truncated request
	}
	var b bytes.Buffer
	fmt.Fprintf(&b, "MESSAGE=%s\n", msg)
	fmt.Fprintf(&b, "PRIORITY=%s\n", priority)
	b.WriteString("SYSLOG_IDENTIFIER=laya-safety-gate\n")
	fmt.Fprintf(&b, "TOOL_NAME=%s\n", oneLine(e.ToolName))
	fmt.Fprintf(&b, "ACTION=%s\n", oneLine(e.Action))
	if truncated {
		b.WriteString("LAYA_TRUNCATED=1\n")
	}
	return b.Bytes()
}

// WriteAudit sends one entry to the journal. A single datagram is delivered
// atomically, so concurrent hook processes never interleave. Errors are
// returned for the caller to ignore: auditing is best-effort and must never
// affect the permission decision.
func WriteAudit(socketPath string, entry AuditEntry) error {
	if entry.Timestamp == "" {
		entry.Timestamp = time.Now().UTC().Format(time.RFC3339)
	}
	conn, err := net.Dial("unixgram", socketPath)
	if err != nil {
		return err
	}
	defer conn.Close()
	conn.SetWriteDeadline(time.Now().Add(time.Second))
	_, err = conn.Write(journalPayload(entry))
	return err
}
