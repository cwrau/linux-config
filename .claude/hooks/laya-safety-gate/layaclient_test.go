package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestQueryLaya_ParsesValidResponse(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/systemone" {
			t.Fatalf("unexpected path %s", r.URL.Path)
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]any{
			"answers": map[string]any{
				"irreversible": map[string]any{"noul": 0.02},
				"mutates":      map[string]any{"noul": 0.81},
				"off_task":     map[string]any{"noul": 0.01},
				"scope":        map[string]any{"choice": "repo"},
			},
		})
	}))
	defer srv.Close()

	v, err := QueryLaya(srv.URL, time.Second, "some state")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if v.Irreversible != 0.02 || v.Mutates != 0.81 || v.OffTask != 0.01 || v.Scope != "repo" {
		t.Fatalf("got %+v", v)
	}
}

func TestQueryLaya_Non2xxIsError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer srv.Close()

	if _, err := QueryLaya(srv.URL, time.Second, "some state"); err == nil {
		t.Fatal("expected error on 500 response")
	}
}

func TestQueryLaya_TimeoutIsError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(50 * time.Millisecond)
	}))
	defer srv.Close()

	if _, err := QueryLaya(srv.URL, 5*time.Millisecond, "some state"); err == nil {
		t.Fatal("expected timeout error")
	}
}

func TestQueryLaya_MalformedJSONIsError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("not json"))
	}))
	defer srv.Close()

	if _, err := QueryLaya(srv.URL, time.Second, "some state"); err == nil {
		t.Fatal("expected error on malformed JSON")
	}
}

func TestQueryLaya_ReportsTruncationFromUsage(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]any{
			"answers": map[string]any{
				"irreversible": map[string]any{"noul": 0.1},
				"mutates":      map[string]any{"noul": 0.1},
				"off_task":     map[string]any{"noul": 0.1},
				"scope":        map[string]any{"choice": "repo"},
			},
			"usage": map[string]any{"truncated": true, "state_tokens_dropped": 42},
		})
	}))
	defer srv.Close()

	v, err := QueryLaya(srv.URL, time.Second, "s")
	if err != nil {
		t.Fatal(err)
	}
	if !v.Truncated || v.TokensDropped != 42 {
		t.Fatalf("expected truncated with 42 dropped, got %+v", v)
	}
}

func TestQueryLaya_NoUsageMeansNotTruncated(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]any{
			"answers": map[string]any{
				"irreversible": map[string]any{"noul": 0.1},
				"mutates":      map[string]any{"noul": 0.1},
				"off_task":     map[string]any{"noul": 0.1},
				"scope":        map[string]any{"choice": "repo"},
			},
		})
	}))
	defer srv.Close()

	v, err := QueryLaya(srv.URL, time.Second, "s")
	if err != nil {
		t.Fatal(err)
	}
	if v.Truncated || v.TokensDropped != 0 {
		t.Fatalf("expected not truncated, got %+v", v)
	}
}

func coreAnswers() map[string]any {
	return map[string]any{
		"irreversible": map[string]any{"noul": 0.1},
		"mutates":      map[string]any{"noul": 0.1},
		"off_task":     map[string]any{"noul": 0.1},
		"scope":        map[string]any{"choice": "repo"},
	}
}

func approxEqual(a, b float64) bool { return a-b < 1e-9 && b-a < 1e-9 }

func TestQueryLaya_ExtractsLoggedOnlySignals(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		a := coreAnswers()
		a["damage"] = map[string]any{"choice": "small", "probabilities": map[string]any{
			"none": 0.1, "small": 0.5, "large": 0.25, "severe": 0.15}}
		a["destructive"] = map[string]any{"noul": 0.4}
		a["off_task_v2"] = map[string]any{"noul": 0.3}
		json.NewEncoder(w).Encode(map[string]any{"answers": a})
	}))
	defer srv.Close()

	v, err := QueryLaya(srv.URL, time.Second, "s")
	if err != nil {
		t.Fatal(err)
	}
	if !approxEqual(v.Signals["damage"], 0.4) || !approxEqual(v.Signals["destructive"], 0.4) || !approxEqual(v.Signals["off_task_v2"], 0.3) {
		t.Fatalf("signals not extracted: %+v", v.Signals)
	}
}

func TestQueryLaya_MissingLoggedOnlySignalsDoNotFail(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]any{"answers": coreAnswers()})
	}))
	defer srv.Close()

	v, err := QueryLaya(srv.URL, time.Second, "s")
	if err != nil {
		t.Fatalf("research signals must never fail the call: %v", err)
	}
	if len(v.Signals) != 0 {
		t.Fatalf("expected no signals, got %+v", v.Signals)
	}
}

func TestQueryLaya_RecordsTruncatedQuestions(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]any{
			"answers": coreAnswers(),
			"usage":   map[string]any{"truncated_questions": []string{"damage"}},
		})
	}))
	defer srv.Close()

	v, err := QueryLaya(srv.URL, time.Second, "s")
	if err != nil {
		t.Fatal(err)
	}
	if len(v.TruncatedQuestions) != 1 || v.TruncatedQuestions[0] != "damage" {
		t.Fatalf("got %+v", v.TruncatedQuestions)
	}
}

func TestQueryLaya_SendsAllQuestionsWithRequiredShapes(t *testing.T) {
	var got map[string]struct {
		Type     string            `json:"type"`
		Criteria map[string]string `json:"criteria"`
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Questions map[string]struct {
				Type     string            `json:"type"`
				Criteria map[string]string `json:"criteria"`
			} `json:"questions"`
		}
		json.NewDecoder(r.Body).Decode(&body)
		got = body.Questions
		json.NewEncoder(w).Encode(map[string]any{"answers": coreAnswers()})
	}))
	defer srv.Close()
	if _, err := QueryLaya(srv.URL, time.Second, "s"); err != nil {
		t.Fatal(err)
	}
	for _, name := range []string{"irreversible", "mutates", "off_task", "scope", "damage", "destructive", "off_task_v2"} {
		if _, ok := got[name]; !ok {
			t.Fatalf("question %q not sent", name)
		}
	}
	if len(got["damage"].Criteria) != 4 || got["damage"].Type != "choice" {
		t.Fatalf("damage must be a 4-option choice: %+v", got["damage"])
	}
	// laya rejects noul criteria that are not keyed exactly true/false.
	for _, name := range []string{"destructive", "off_task_v2"} {
		c := got[name].Criteria
		if len(c) != 2 || c["true"] == "" || c["false"] == "" {
			t.Fatalf("%s criteria must be keyed true/false: %+v", name, c)
		}
	}
}
