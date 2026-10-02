package main

import (
	"encoding/json"
	"os"
)

// LoadConfig reads laya-safety-config.json from path. If the file is
// missing or fails to parse, it returns DefaultConfig() rather than an
// error -- per the spec's Review Focus, the hook must never crash or
// silently disable itself just because its config has a typo or hasn't
// been created yet.
func LoadConfig(path string) Config {
	data, err := os.ReadFile(path)
	if err != nil {
		return DefaultConfig()
	}
	var cfg Config
	if err := json.Unmarshal(data, &cfg); err != nil {
		return DefaultConfig()
	}
	return cfg
}
