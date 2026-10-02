package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"
)

// maxToolInputChars bounds how much of tool_input's compact JSON
// rendering is included in the state sent to laya -- an unbounded Write
// call with megabytes of file content would otherwise blow both laya's
// token budget and the hook's own latency budget.
const maxToolInputChars = 2000

// maxTaskChars caps the task text. laya drops tokens from the end of an
// over-long state, and in subagent sessions the "last user message" is the
// whole prompt, so an uncapped task pushed the command out of the window.
const maxTaskChars = 600

// maxAuditInputChars bounds the tool_input excerpt stored per audit line.
const maxAuditInputChars = 200

const modeLogOnly = "log-only"

func main() {
	defer recoverToAsk(os.Stdout)
	run(os.Stdin, os.Stdout)
}

func run(in io.Reader, out io.Writer) {
	home, err := os.UserHomeDir()
	if err != nil {
		home = "/root"
	}
	runWith(in, out, home)
}

func truncate(s string, max int) string {
	if len(s) > max {
		return s[:max] + "...(truncated)"
	}
	return s
}

func runWith(in io.Reader, out io.Writer, home string) {
	var input HookInput
	if err := json.NewDecoder(in).Decode(&input); err != nil {
		emit(out, askOutput("laya-safety-gate: could not parse hook input"))
		return
	}

	cfg := LoadConfig(filepath.Join(home, ".claude", "hooks", "laya-safety-config.json"))

	if IsAllowlisted(input.ToolName, cfg.Allowlist) {
		return // no output at all: zero-latency pass-through, not logged
	}

	start := time.Now()
	task := LastUserMessage(input.TranscriptPath)
	state := buildState(task, input.ToolName, input.ToolInput)

	verdict, queryErr := QueryLaya(cfg.LayaURL, time.Duration(cfg.TimeoutMS)*time.Millisecond, state)
	latency := time.Since(start).Milliseconds()

	var decision, reason string
	var verdictPtr *Verdict
	if queryErr != nil {
		decision, reason = FailureDecision("laya-serve error: " + queryErr.Error())
	} else {
		decision, reason = Decide(verdict, cfg.Thresholds)
		verdictPtr = &verdict
	}

	_ = WriteAudit(auditSocketPath, AuditEntry{
		ToolName:  input.ToolName,
		Input:     truncate(string(input.ToolInput), maxAuditInputChars),
		Verdict:   verdictPtr,
		Action:    decision,
		Reason:    reason,
		LatencyMS: latency,
	})

	if cfg.Mode == modeLogOnly {
		return // scored and logged, but no decision emitted
	}

	result := HookOutput{HookSpecificOutput: HookSpecificOutput{
		HookEventName:            "PreToolUse",
		PermissionDecision:       decision,
		PermissionDecisionReason: reason,
	}}
	if decision == DecisionDeny {
		result.SystemMessage = "laya-safety-gate blocked this call: " + reason
	}
	emit(out, result)
}

func buildState(task, toolName string, toolInput json.RawMessage) string {
	compact := truncate(string(toolInput), maxToolInputChars)
	return fmt.Sprintf("Tool: %s\nInput: %s\nTask: %s", toolName, compact, truncate(task, maxTaskChars))
}

func askOutput(reason string) HookOutput {
	return HookOutput{HookSpecificOutput: HookSpecificOutput{
		HookEventName:            "PreToolUse",
		PermissionDecision:       DecisionAsk,
		PermissionDecisionReason: reason,
	}}
}

func emit(out io.Writer, o HookOutput) {
	data, err := json.Marshal(o)
	if err != nil {
		return
	}
	fmt.Fprintln(out, string(data))
}

func recoverToAsk(out io.Writer) {
	if r := recover(); r != nil {
		emit(out, askOutput(fmt.Sprintf("laya-safety-gate panic: %v", r)))
	}
}
