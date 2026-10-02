package main

import "testing"

func TestIsAllowlisted_ExactName(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	if !IsAllowlisted("Read", cfg) {
		t.Fatal("expected Read to be allowlisted")
	}
}

func TestIsAllowlisted_McpPattern(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	if !IsAllowlisted("mcp__capi-shell-mcp__pods_list", cfg) {
		t.Fatal("expected pods_list (_list pattern) to be allowlisted")
	}
	if !IsAllowlisted("mcp__capi-shell-mcp__exec_in_cluster_readonly", cfg) {
		t.Fatal("expected _readonly suffix to be allowlisted")
	}
}

func TestIsAllowlisted_UnknownDefaultsToChecked(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	if IsAllowlisted("Bash", cfg) {
		t.Fatal("Bash must never be allowlisted")
	}
	if IsAllowlisted("mcp__some-server__delete_everything", cfg) {
		t.Fatal("unrecognized destructive-looking MCP tool must default to checked")
	}
}

func TestIsAllowlisted_SubstringInsideWordDoesNotMatch(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	// "forget_all" contains "get_" but is not a getter.
	if IsAllowlisted("mcp__some-server__forget_all", cfg) {
		t.Fatal("forget_all must not be allowlisted via a get_ substring")
	}
}

func TestIsAllowlisted_MutatingVerbBeforeListSuffixDoesNotMatch(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	for _, name := range []string{
		"mcp__s__delete_list", "mcp__s__clear_list", "mcp__s__reset_get", "mcp__s__send_list",
	} {
		if IsAllowlisted(name, cfg) {
			t.Fatalf("%s must not be allowlisted", name)
		}
	}
}

func TestIsAllowlisted_ServerNameDoesNotInfluenceMatch(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	// Only the tool segment (after the last "__") may match, never the server name.
	if IsAllowlisted("mcp__get_server__delete_everything", cfg) {
		t.Fatal("server name containing get_ must not allowlist a destructive tool")
	}
	if IsAllowlisted("mcp__list_stuff__apply_changes", cfg) {
		t.Fatal("server name containing list_ must not allowlist apply_changes")
	}
}

func TestIsAllowlisted_ReadVerbPrefixAndNounListSuffixStillMatch(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	for _, name := range []string{
		"mcp__s__get_pod", "mcp__s__list_namespaces", "mcp__s__search_emails",
		"mcp__s__read_email", "mcp__s__pods_list", "mcp__s__widget_get",
		"mcp__s__exec_in_cluster_readonly",
	} {
		if !IsAllowlisted(name, cfg) {
			t.Fatalf("%s should be allowlisted", name)
		}
	}
}

func TestIsAllowlisted_SkillAndToolSearch(t *testing.T) {
	cfg := DefaultConfig().Allowlist
	for _, name := range []string{"Skill", "ToolSearch"} {
		if !IsAllowlisted(name, cfg) {
			t.Fatalf("%s should be allowlisted", name)
		}
	}
}
