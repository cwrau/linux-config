package main

import "strings"

// toolSegment returns the part of an MCP tool name after the last "__"
// ("mcp__server__get_pod" -> "get_pod"), or the whole name for built-ins.
// Matching only this segment keeps a server name like "get_server" from
// allowlisting every tool it exposes.
func toolSegment(toolName string) string {
	if i := strings.LastIndex(toolName, "__"); i >= 0 {
		return toolName[i+2:]
	}
	return toolName
}

func hasAnyPrefix(s string, prefixes []string) bool {
	for _, p := range prefixes {
		if strings.HasPrefix(s, p) {
			return true
		}
	}
	return false
}

func hasAnySuffix(s string, suffixes []string) bool {
	for _, p := range suffixes {
		if strings.HasSuffix(s, p) {
			return true
		}
	}
	return false
}

// IsAllowlisted reports whether toolName should skip laya entirely -- the
// zero-added-latency fast path from the spec's "Local allowlist" section.
// Order: exact name, then read-verb prefix on the tool segment, then a
// read-noun suffix unless a mutating verb leads the segment. Anything
// unrecognized returns false ("go check it with laya").
func IsAllowlisted(toolName string, cfg AllowlistConfig) bool {
	for _, name := range cfg.ExactNames {
		if toolName == name {
			return true
		}
	}
	seg := toolSegment(toolName)
	if hasAnyPrefix(seg, cfg.NamePrefixes) {
		return true
	}
	if hasAnySuffix(seg, cfg.NameSuffixes) && !hasAnyPrefix(seg, cfg.MutatingPrefixes) {
		return true
	}
	return false
}
