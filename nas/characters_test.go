package main

import (
	"bytes"
	"encoding/json"
	"io"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"testing"
)

// newTestServer wires a server on a temp data dir — same construction main()
// does, minus the listener.
func newTestServer(t *testing.T) (*Server, *http.ServeMux) {
	t.Helper()
	dir := t.TempDir()
	store, err := OpenStore(filepath.Join(dir, "test.db"))
	if err != nil {
		t.Fatalf("open store: %v", err)
	}
	s := &Server{store: store, broker: NewBroker(), data: dir, fcKeys: map[string]bool{}}
	mux := http.NewServeMux()
	s.routeFC(mux)
	return s, mux
}

func do(t *testing.T, mux *http.ServeMux, method, path string, body io.Reader, ctype string) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequest(method, path, body)
	if ctype != "" {
		req.Header.Set("Content-Type", ctype)
	}
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	return rec
}

func addAnimation(t *testing.T, mux *http.ServeMux, id string) {
	t.Helper()
	body, _ := json.Marshal(Animation{
		Name: id, Category: "idle", Source: "mixamo", License: "mixamo-embedded",
		FBXPath: "/data/animlib/" + id + ".fbx", Frames: 60, FPS: 30, Loop: true,
	})
	if rec := do(t, mux, "PUT", "/v1/fc/animations/"+id, bytes.NewReader(body), "application/json"); rec.Code != 200 {
		t.Fatalf("upsert animation: %d %s", rec.Code, rec.Body)
	}
}

func createCharacter(t *testing.T, mux *http.ServeMux, animIDs ...string) *Character {
	t.Helper()
	var buf bytes.Buffer
	mw := multipart.NewWriter(&buf)
	mw.WriteField("name", "Sir Testalot")
	for _, id := range animIDs {
		mw.WriteField("animation_ids", id)
	}
	f, _ := mw.CreateFormFile("image", "knight.png")
	f.Write([]byte("\x89PNG\r\n\x1a\n fake"))
	mw.Close()

	rec := do(t, mux, "POST", "/v1/fc/characters", &buf, mw.FormDataContentType())
	if rec.Code != http.StatusAccepted {
		t.Fatalf("create: %d %s", rec.Code, rec.Body)
	}
	var c Character
	json.Unmarshal(rec.Body.Bytes(), &c)
	return &c
}

// claimAndFinish runs one worker cycle and returns the step it handled.
func claimAndFinish(t *testing.T, mux *http.ServeMux, result map[string]any) string {
	t.Helper()
	rec := do(t, mux, "POST", "/worker/fc/claim", nil, "")
	if rec.Code == http.StatusNoContent {
		return ""
	}
	if rec.Code != 200 {
		t.Fatalf("claim: %d %s", rec.Code, rec.Body)
	}
	var claim struct {
		StepID int64  `json:"step_id"`
		Step   string `json:"step"`
		Clips  []struct {
			ID string `json:"id"`
		} `json:"clips"`
	}
	json.Unmarshal(rec.Body.Bytes(), &claim)
	if result == nil {
		result = map[string]any{}
	}
	body, _ := json.Marshal(result)
	rec = do(t, mux, "POST", "/worker/fc/result/"+itoa(claim.StepID), bytes.NewReader(body), "application/json")
	if rec.Code != 200 {
		t.Fatalf("result for %s: %d %s", claim.Step, rec.Code, rec.Body)
	}
	return claim.Step
}

func itoa(n int64) string {
	b, _ := json.Marshal(n)
	return string(b)
}

func getCharacter(t *testing.T, mux *http.ServeMux, id string) *Character {
	t.Helper()
	rec := do(t, mux, "GET", "/v1/fc/characters/"+id, nil, "")
	if rec.Code != 200 {
		t.Fatalf("get: %d %s", rec.Code, rec.Body)
	}
	var out struct {
		Character *Character `json:"character"`
	}
	json.Unmarshal(rec.Body.Bytes(), &out)
	return out.Character
}

// TestPipelineToDone is the plan's phase-3 acceptance: upload walks every step
// and lands on done.
func TestPipelineToDone(t *testing.T) {
	_, mux := newTestServer(t)
	addAnimation(t, mux, "idle_01")
	c := createCharacter(t, mux, "idle_01")
	if c.Status != "uploaded" {
		t.Fatalf("fresh character is %q, want uploaded", c.Status)
	}

	want := []string{StepPreprocess, StepMesh, StepClean, StepRig, StepAnimate, StepExportUser}
	for i, wantStep := range want {
		result := map[string]any{}
		switch wantStep {
		case StepRig:
			result["artifacts"] = map[string]any{"rigged_fbx": "/data/characters/x/rigged.fbx"}
		case StepAnimate:
			result["frame_ranges"] = map[string][]int64{"idle_01": {1, 60}}
		case StepExportUser:
			result["artifacts"] = map[string]any{"final_glb": "/data/characters/x/model.glb"}
		}
		got := claimAndFinish(t, mux, result)
		if got != wantStep {
			t.Fatalf("step %d: worker got %q, want %q", i, got, wantStep)
		}
	}
	if step := claimAndFinish(t, mux, nil); step != "" {
		t.Fatalf("queue should be empty, got %q", step)
	}
	if c := getCharacter(t, mux, c.ID); c.Status != "done" {
		t.Fatalf("final status %q, want done", c.Status)
	}
}

// TestStepFailureAndRetry: a failed step parks the character and retry queues
// exactly that step again — the per-step retry the plan asks for.
func TestStepFailureAndRetry(t *testing.T) {
	s, mux := newTestServer(t)
	addAnimation(t, mux, "idle_01")
	c := createCharacter(t, mux, "idle_01")

	claimAndFinish(t, mux, nil)                                              // preprocess ok
	claimAndFinish(t, mux, map[string]any{"error": "TRELLIS out of memory"}) // mesh fails

	got := getCharacter(t, mux, c.ID)
	if got.Status != "failed" {
		t.Fatalf("status %q, want failed", got.Status)
	}
	if got.Error == "" {
		t.Fatal("failed character carries no error")
	}

	rec := do(t, mux, "POST", "/v1/fc/characters/"+c.ID+"/retry", bytes.NewReader([]byte(`{}`)), "application/json")
	if rec.Code != http.StatusAccepted {
		t.Fatalf("retry: %d %s", rec.Code, rec.Body)
	}
	if step := claimAndFinish(t, mux, nil); step != StepMesh {
		t.Fatalf("retry queued %q, want %q", step, StepMesh)
	}
	steps, _ := s.store.ListSteps(c.ID)
	var meshAttempts int64
	for _, st := range steps {
		if st.Step == StepMesh {
			meshAttempts = st.Attempt
		}
	}
	if meshAttempts != 2 {
		t.Fatalf("mesh retry is attempt %d, want 2", meshAttempts)
	}
}

// TestFrameRangesReachTheApp — retarget.py's merged timeline is what lets the
// viewer play a named clip, so it has to survive the round trip.
func TestFrameRangesReachTheApp(t *testing.T) {
	_, mux := newTestServer(t)
	addAnimation(t, mux, "idle_01")
	addAnimation(t, mux, "walk_forward")
	c := createCharacter(t, mux, "idle_01", "walk_forward")

	for _, step := range []string{StepPreprocess, StepMesh, StepClean, StepRig} {
		if got := claimAndFinish(t, mux, nil); got != step {
			t.Fatalf("got %q, want %q", got, step)
		}
	}
	claimAndFinish(t, mux, map[string]any{
		"frame_ranges": map[string][]int64{"idle_01": {1, 60}, "walk_forward": {65, 125}},
	})

	rec := do(t, mux, "GET", "/v1/fc/characters/"+c.ID, nil, "")
	var out struct {
		Animations []CharacterAnimation `json:"animations"`
	}
	json.Unmarshal(rec.Body.Bytes(), &out)
	if len(out.Animations) != 2 {
		t.Fatalf("got %d clips, want 2", len(out.Animations))
	}
	if out.Animations[0].AnimationID != "idle_01" || out.Animations[0].FrameEnd != 60 {
		t.Fatalf("first clip %+v", out.Animations[0])
	}
	if out.Animations[1].FrameStart != 65 || out.Animations[1].FrameEnd != 125 {
		t.Fatalf("second clip %+v", out.Animations[1])
	}
}

// TestUnknownAnimationRejected keeps a typo in the app from creating a
// character the animate step could never finish.
func TestUnknownAnimationRejected(t *testing.T) {
	_, mux := newTestServer(t)
	var buf bytes.Buffer
	mw := multipart.NewWriter(&buf)
	mw.WriteField("name", "Ghost")
	mw.WriteField("animation_ids", "does_not_exist")
	f, _ := mw.CreateFormFile("image", "x.png")
	f.Write([]byte("png"))
	mw.Close()
	if rec := do(t, mux, "POST", "/v1/fc/characters", &buf, mw.FormDataContentType()); rec.Code != 400 {
		t.Fatalf("got %d, want 400", rec.Code)
	}
}

// TestFCAuth: with keys configured the scope is closed.
func TestFCAuth(t *testing.T) {
	s, mux := newTestServer(t)
	s.fcKeys = map[string]bool{"secret": true}

	if rec := do(t, mux, "GET", "/v1/fc/animations", nil, ""); rec.Code != 401 {
		t.Fatalf("unauthenticated got %d, want 401", rec.Code)
	}
	req := httptest.NewRequest("GET", "/v1/fc/animations", nil)
	req.Header.Set("X-API-Key", "secret")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != 200 {
		t.Fatalf("authenticated got %d, want 200", rec.Code)
	}
}

// TestExportRequiresFinalModel — no point packing for Roblox before there is
// a model to pack.
func TestExportRequiresFinalModel(t *testing.T) {
	_, mux := newTestServer(t)
	addAnimation(t, mux, "idle_01")
	c := createCharacter(t, mux, "idle_01")

	body := []byte(`{"target":"roblox"}`)
	if rec := do(t, mux, "POST", "/v1/fc/characters/"+c.ID+"/export", bytes.NewReader(body), "application/json"); rec.Code != 409 {
		t.Fatalf("got %d, want 409", rec.Code)
	}
	if rec := do(t, mux, "POST", "/v1/fc/characters/"+c.ID+"/export",
		bytes.NewReader([]byte(`{"target":"minecraft"}`)), "application/json"); rec.Code != 400 {
		t.Fatalf("bad target got %d, want 400", rec.Code)
	}
}

// TestExportStepClosesExportRow: the worker's result has to land on the
// export row, otherwise the app never learns the Roblox assetId.
func TestExportStepClosesExportRow(t *testing.T) {
	s, mux := newTestServer(t)
	addAnimation(t, mux, "idle_01")
	c := createCharacter(t, mux, "idle_01")
	for range pipeline {
		claimAndFinish(t, mux, map[string]any{
			"artifacts": map[string]any{"final_glb": "/data/characters/x/model.glb"},
		})
	}

	rec := do(t, mux, "POST", "/v1/fc/characters/"+c.ID+"/export",
		bytes.NewReader([]byte(`{"target":"roblox"}`)), "application/json")
	if rec.Code != http.StatusAccepted {
		t.Fatalf("export: %d %s", rec.Code, rec.Body)
	}
	var e Export
	json.Unmarshal(rec.Body.Bytes(), &e)

	if step := claimAndFinish(t, mux, map[string]any{"external_id": "rbxassetid://123"}); step != "char.export.roblox" {
		t.Fatalf("worker claimed %q", step)
	}
	got, err := s.store.GetExport(e.ID)
	if err != nil {
		t.Fatalf("get export: %v", err)
	}
	if got.Status != "done" || got.ExternalID != "rbxassetid://123" {
		t.Fatalf("export row %+v", got)
	}
	// export nesmi shodit hotovou postavu ze stavu done
	if c := getCharacter(t, mux, c.ID); c.Status != "done" {
		t.Fatalf("status after export %q, want done", c.Status)
	}
}
