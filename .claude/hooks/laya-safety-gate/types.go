package main

import "encoding/json"

// HookInput models the subset of Claude Code's PreToolUse JSON stdin
// payload this hook reads. See https://code.claude.com/docs/en/hooks
type HookInput struct {
	SessionID      string          `json:"session_id"`
	TranscriptPath string          `json:"transcript_path"`
	CWD            string          `json:"cwd"`
	PermissionMode string          `json:"permission_mode"`
	ToolName       string          `json:"tool_name"`
	ToolInput      json.RawMessage `json:"tool_input"`
}

// HookOutput is the PreToolUse JSON this hook prints on stdout.
type HookOutput struct {
	HookSpecificOutput HookSpecificOutput `json:"hookSpecificOutput"`
	SystemMessage      string             `json:"systemMessage,omitempty"`
}

type HookSpecificOutput struct {
	HookEventName            string `json:"hookEventName"`
	PermissionDecision       string `json:"permissionDecision"`
	PermissionDecisionReason string `json:"permissionDecisionReason,omitempty"`
}

const (
	DecisionAllow = "allow"
	DecisionDeny  = "deny"
	DecisionAsk   = "ask"
)

// AllowlistConfig lists tool names/patterns the hook never sends to laya.
type AllowlistConfig struct {
	ExactNames []string `json:"exact_names"`
	// Matched against the tool segment only (after the last "__").
	NamePrefixes []string `json:"name_prefixes"`
	NameSuffixes []string `json:"name_suffixes"`
	// A tool segment starting with one of these is never allowlisted via a
	// suffix match, so "delete_list" is not mistaken for a lister.
	MutatingPrefixes []string `json:"mutating_prefixes"`
}

// Thresholds is the decision policy from the spec's "Decision policy" section.
type Thresholds struct {
	AllowMaxIrreversible     float64 `json:"allow_max_irreversible"`
	AllowMaxMutates          float64 `json:"allow_max_mutates"`
	AllowMaxOffTask          float64 `json:"allow_max_off_task"`
	DenyMinIrreversible      float64 `json:"deny_min_irreversible"`
	DenyMinMutatesAndOffTask float64 `json:"deny_min_mutates_and_off_task"`
}

// Config is the full laya-safety-config.json shape.
type Config struct {
	// Mode "log-only" scores and logs but emits no decision; any other
	// value (including empty or a typo) enforces.
	Mode       string          `json:"mode"`
	LayaURL    string          `json:"laya_url"`
	TimeoutMS  int             `json:"timeout_ms"`
	Allowlist  AllowlistConfig `json:"allowlist"`
	Thresholds Thresholds      `json:"thresholds"`
}

// DefaultConfig is used whenever laya-safety-config.json is missing or
// fails to parse -- the hook must never crash or silently disable itself
// just because its config file has a typo or hasn't been created yet.
func DefaultConfig() Config {
	return Config{
		LayaURL:   "http://127.0.0.1:8000",
		TimeoutMS: 2000,
		Allowlist: AllowlistConfig{
			ExactNames: []string{
				"Read", "Grep", "Glob", "TodoWrite", "NotebookRead",
				"ExitPlanMode", "AskUserQuestion", "WebSearch", "WebFetch",
				"Skill", "ToolSearch",
			},
			NamePrefixes: []string{"get_", "list_", "search_", "read_"},
			NameSuffixes: []string{"_readonly", "_get", "_list"},
			MutatingPrefixes: []string{
				"delete_", "remove_", "create_", "set_", "update_", "send_",
				"write_", "clear_", "reset_", "drop_", "add_", "put_", "post_",
			},
		},
		Thresholds: Thresholds{
			AllowMaxIrreversible:     0.05,
			AllowMaxMutates:          0.05,
			AllowMaxOffTask:          0.05,
			DenyMinIrreversible:      1.0, // disabled: probabilities never exceed 1.0
			DenyMinMutatesAndOffTask: 0.7,
		},
	}
}

// Verdict is laya's answer to the four typed questions, extracted from
// its POST /v1/systemone response.
type Verdict struct {
	Irreversible float64 `json:"irreversible"`
	Mutates      float64 `json:"mutates"`
	OffTask      float64 `json:"off_task"`
	Scope        string  `json:"scope"`
	// Truncated means laya dropped part of the input (TokensDropped tokens),
	// so the scores judged an incomplete request and are unreliable.
	Truncated     bool `json:"truncated,omitempty"`
	TokensDropped int  `json:"tokens_dropped,omitempty"`
	// TruncatedQuestions names questions whose option text laya had to cut.
	TruncatedQuestions []string `json:"truncated_questions,omitempty"`
	// Signals are research-only scores logged for threshold tuning; the
	// decision policy never reads them.
	Signals map[string]float64 `json:"signals,omitempty"`
}

// AuditEntry is one line of ~/.claude/laya-safety-audit.jsonl.
type AuditEntry struct {
	Timestamp string   `json:"ts"`
	ToolName  string   `json:"tool_name"`
	Input     string   `json:"input,omitempty"`
	Verdict   *Verdict `json:"verdict,omitempty"`
	Action    string   `json:"action"`
	Reason    string   `json:"reason"`
	LatencyMS int64    `json:"latency_ms"`
}
