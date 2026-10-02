package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLoadConfig_MissingFileReturnsDefault(t *testing.T) {
	cfg := LoadConfig(filepath.Join(t.TempDir(), "does-not-exist.json"))
	def := DefaultConfig()
	if cfg.LayaURL != def.LayaURL || cfg.TimeoutMS != def.TimeoutMS {
		t.Fatalf("expected default config, got %+v", cfg)
	}
}

func TestLoadConfig_CorruptFileReturnsDefault(t *testing.T) {
	path := filepath.Join(t.TempDir(), "bad.json")
	if err := os.WriteFile(path, []byte("{not valid json"), 0o644); err != nil {
		t.Fatal(err)
	}
	cfg := LoadConfig(path)
	def := DefaultConfig()
	if cfg.TimeoutMS != def.TimeoutMS {
		t.Fatalf("expected default config on corrupt file, got %+v", cfg)
	}
}

func TestLoadConfig_ValidFileOverridesDefaults(t *testing.T) {
	path := filepath.Join(t.TempDir(), "good.json")
	content := `{"laya_url":"http://127.0.0.1:9999","timeout_ms":500,"allowlist":{"exact_names":["Read"],"name_patterns":[]},"thresholds":{"allow_max_irreversible":0.1,"allow_max_mutates":0.1,"allow_max_off_task":0.1,"deny_min_irreversible":0.5,"deny_min_mutates_and_off_task":0.5}}`
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	cfg := LoadConfig(path)
	if cfg.LayaURL != "http://127.0.0.1:9999" || cfg.TimeoutMS != 500 {
		t.Fatalf("expected overridden config, got %+v", cfg)
	}
}
