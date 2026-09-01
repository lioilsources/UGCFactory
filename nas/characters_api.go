package main

// The fantasy-character API (docs/FANTASYCHARACTER_PLAN.md §3.2). Lives on its
// own /v1/fc/ prefix with its own key scope, so the FC mobile app and the
// ugc_studio admin app never share credentials.

import (
	"archive/zip"
	"encoding/json"
	"fmt"
	"html"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

// charFiles maps a pipeline artifact to its name inside /data/characters/{id}.
var charFiles = map[string]string{
	"source_image": "source.png",
	"apose_image":  "apose.png",
	"mesh_glb":     "mesh.glb",
	"clean_glb":    "clean.glb",
	"rigged_fbx":   "rigged.fbx",
	"final_glb":    "model.glb",
	"final_fbx":    "model.fbx",
	"preview_mp4":  "preview.mp4",
	"thumb_png":    "thumb.png",
}

func (s *Server) charDir(id string) string {
	return filepath.Join(s.data, "characters", id)
}

// fcAuth guards the FC scope. Unset FC_API_KEYS keeps the LAN open, the same
// deal the rest of the API has with Cloudflare Access at the edge.
func (s *Server) fcAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if len(s.fcKeys) == 0 {
			next(w, r)
			return
		}
		key := r.Header.Get("X-API-Key")
		if key == "" {
			key = strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
		}
		if !s.fcKeys[key] {
			httpErr(w, http.StatusUnauthorized, "invalid or missing FC api key")
			return
		}
		next(w, r)
	}
}

func (s *Server) routeFC(mux *http.ServeMux) {
	h := func(pattern string, fn http.HandlerFunc) { mux.HandleFunc(pattern, s.fcAuth(fn)) }

	h("POST /v1/fc/characters", s.handleFCCreate)
	h("GET /v1/fc/characters", s.handleFCList)
	h("GET /v1/fc/characters/{id}", s.handleFCGet)
	h("DELETE /v1/fc/characters/{id}", s.handleFCDelete)
	h("POST /v1/fc/characters/{id}/retry", s.handleFCRetry)
	h("POST /v1/fc/characters/{id}/animations", s.handleFCSetAnimations)
	h("GET /v1/fc/characters/{id}/download", s.handleFCDownload)
	h("GET /v1/fc/characters/{id}/file/{artifact}", s.handleFCFile)
	h("GET /v1/fc/characters/{id}/events", s.handleFCEvents)
	h("GET /v1/fc/characters/{id}/viewer", s.handleFCViewer)
	h("POST /v1/fc/characters/{id}/export", s.handleFCExport)
	h("GET /v1/fc/exports/{id}", s.handleFCGetExport)
	h("GET /v1/fc/animations", s.handleFCListAnimations)
	h("PUT /v1/fc/animations/{id}", s.handleFCUpsertAnimation)

	// worker-only, stejne jako /worker/claim: v compose siti, tunnel je nepublikuje
	mux.HandleFunc("POST /worker/fc/claim", s.handleFCWorkerClaim)
	mux.HandleFunc("POST /worker/fc/result/{step}", s.handleFCWorkerResult)
}

// handleFCCreate takes the app's upload and starts the pipeline.
func (s *Server) handleFCCreate(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(maxUpload); err != nil {
		httpErr(w, http.StatusBadRequest, "multipart: %v", err)
		return
	}
	c := &Character{
		ID:        newID(),
		OwnerID:   r.FormValue("owner_id"),
		Name:      strings.TrimSpace(r.FormValue("name")),
		Status:    "uploaded",
		AutoAPose: r.FormValue("auto_apose") != "false",
	}
	if c.Name == "" {
		httpErr(w, http.StatusBadRequest, "missing name")
		return
	}
	animIDs := formList(r, "animation_ids")
	if len(animIDs) == 0 {
		httpErr(w, http.StatusBadRequest, "pick at least one animation")
		return
	}
	for _, id := range animIDs {
		if _, err := s.store.GetAnimation(id); err != nil {
			httpErr(w, http.StatusBadRequest, "unknown animation %q", id)
			return
		}
	}

	dir := s.charDir(c.ID)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	if err := saveFormFile(r, "image", filepath.Join(dir, charFiles["source_image"])); err != nil {
		os.RemoveAll(dir)
		httpErr(w, http.StatusBadRequest, "image: %v", err)
		return
	}
	c.SourceImage = filepath.Join(dir, charFiles["source_image"])

	if err := s.store.InsertCharacter(c); err != nil {
		os.RemoveAll(dir)
		httpErr(w, http.StatusInternalServerError, "insert: %v", err)
		return
	}
	if err := s.store.SetCharacterAnimations(c.ID, animIDs); err != nil {
		httpErr(w, http.StatusInternalServerError, "animations: %v", err)
		return
	}
	if _, err := s.store.EnqueueStep(c.ID, pipeline[0].Step); err != nil {
		httpErr(w, http.StatusInternalServerError, "enqueue: %v", err)
		return
	}
	s.publishCharacter("character.created", c)
	writeJSON(w, http.StatusAccepted, c)
}

// formList reads a repeated field, and also tolerates one comma-separated
// value — multipart clients differ and both spellings reach here.
func formList(r *http.Request, field string) []string {
	var out []string
	for _, v := range r.Form[field] {
		for _, part := range strings.Split(v, ",") {
			if p := strings.TrimSpace(part); p != "" {
				out = append(out, p)
			}
		}
	}
	return out
}

func (s *Server) handleFCList(w http.ResponseWriter, r *http.Request) {
	limit := 200
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 1000 {
			limit = n
		}
	}
	list, err := s.store.ListCharacters(r.URL.Query().Get("owner"),
		r.URL.Query().Get("status"), limit)
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	writeJSON(w, http.StatusOK, list)
}

func (s *Server) characterOr404(w http.ResponseWriter, id string) *Character {
	if !validID(id) {
		httpErr(w, http.StatusBadRequest, "invalid id")
		return nil
	}
	c, err := s.store.GetCharacter(id)
	if err != nil {
		httpErr(w, http.StatusNotFound, "character %s not found", id)
		return nil
	}
	return c
}

// handleFCGet is what the app polls between SSE events: status, the clips with
// their frame ranges, per-step history and URLs for whatever already exists.
func (s *Server) handleFCGet(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	anims, err := s.store.ListCharacterAnimations(c.ID)
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	steps, _ := s.store.ListSteps(c.ID)
	exports, _ := s.store.ListExports(c.ID)
	writeJSON(w, http.StatusOK, map[string]any{
		"character":  c,
		"animations": anims,
		"steps":      steps,
		"exports":    exports,
		"artifacts":  s.artifactURLs(c),
	})
}

// artifactURLs lists only files that are actually on disk, so the app can bind
// buttons to presence instead of guessing from status.
func (s *Server) artifactURLs(c *Character) map[string]string {
	out := map[string]string{}
	for artifact, name := range charFiles {
		if _, err := os.Stat(filepath.Join(s.charDir(c.ID), name)); err == nil {
			out[artifact] = fmt.Sprintf("/v1/fc/characters/%s/file/%s", c.ID, artifact)
		}
	}
	return out
}

func (s *Server) handleFCFile(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	name, ok := charFiles[r.PathValue("artifact")]
	if !ok {
		httpErr(w, http.StatusNotFound, "unknown artifact %q", r.PathValue("artifact"))
		return
	}
	http.ServeFile(w, r, filepath.Join(s.charDir(c.ID), name))
}

func (s *Server) handleFCDelete(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	if err := s.store.DeleteCharacter(c.ID); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	os.RemoveAll(s.charDir(c.ID))
	s.publishCharacter("character.deleted", c)
	w.WriteHeader(http.StatusNoContent)
}

// handleFCRetry re-runs one step. Without from_step it picks up where the
// pipeline died, which is what the app's "try again" button wants.
func (s *Server) handleFCRetry(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	var body struct {
		FromStep string `json:"from_step"`
	}
	json.NewDecoder(r.Body).Decode(&body)

	step := body.FromStep
	if step == "" {
		step = s.failedStep(c.ID)
	}
	if step == "" {
		httpErr(w, http.StatusConflict, "nothing to retry for %s", c.ID)
		return
	}
	if !knownStep(step) {
		httpErr(w, http.StatusBadRequest, "unknown step %q", step)
		return
	}
	if _, err := s.store.EnqueueStep(c.ID, step); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	// zpet na stav pred timto krokem, at UI neukazuje 'failed' behem retry
	s.store.SetCharacterStatus(c.ID, statusBefore(step), "failed", c.Status)
	c, _ = s.store.GetCharacter(c.ID)
	s.publishCharacter("character.updated", c)
	writeJSON(w, http.StatusAccepted, c)
}

// failedStep is the last step that failed and was never retried since.
func (s *Server) failedStep(characterID string) string {
	steps, err := s.store.ListSteps(characterID)
	if err != nil {
		return ""
	}
	for i := len(steps) - 1; i >= 0; i-- {
		if steps[i].Status == "failed" {
			return steps[i].Step
		}
	}
	return ""
}

// statusBefore is the status a character holds while step is queued.
func statusBefore(step string) string {
	prev := "uploaded"
	for _, p := range pipeline {
		if p.Step == step {
			return prev
		}
		prev = p.Status
	}
	return "done" // export steps run on a finished character
}

// handleFCSetAnimations swaps the clip selection and re-runs animate+export,
// the cheap path when the mesh is fine and only the moves should change.
func (s *Server) handleFCSetAnimations(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	var body struct {
		AnimationIDs []string `json:"animation_ids"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}
	if len(body.AnimationIDs) == 0 {
		httpErr(w, http.StatusBadRequest, "pick at least one animation")
		return
	}
	if c.RiggedFBX == "" {
		httpErr(w, http.StatusConflict, "character %s is not rigged yet", c.ID)
		return
	}
	for _, id := range body.AnimationIDs {
		if _, err := s.store.GetAnimation(id); err != nil {
			httpErr(w, http.StatusBadRequest, "unknown animation %q", id)
			return
		}
	}
	if err := s.store.SetCharacterAnimations(c.ID, body.AnimationIDs); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	if _, err := s.store.EnqueueStep(c.ID, StepAnimate); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	s.store.SetCharacterStatus(c.ID, "rigged", c.Status)
	c, _ = s.store.GetCharacter(c.ID)
	s.publishCharacter("character.updated", c)
	writeJSON(w, http.StatusAccepted, c)
}

// handleFCDownload serves one artifact, or zips the user bundle.
func (s *Server) handleFCDownload(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	dir := s.charDir(c.ID)
	switch r.URL.Query().Get("format") {
	case "glb", "":
		http.ServeFile(w, r, filepath.Join(dir, charFiles["final_glb"]))
	case "fbx":
		http.ServeFile(w, r, filepath.Join(dir, charFiles["final_fbx"]))
	case "zip":
		w.Header().Set("Content-Type", "application/zip")
		w.Header().Set("Content-Disposition",
			fmt.Sprintf("attachment; filename=%q", safeName(c.Name, c.ID)+".zip"))
		zw := zip.NewWriter(w)
		defer zw.Close()
		for _, artifact := range []string{"final_glb", "final_fbx", "preview_mp4", "thumb_png"} {
			name := charFiles[artifact]
			f, err := os.Open(filepath.Join(dir, name))
			if err != nil {
				continue
			}
			if dst, err := zw.Create(name); err == nil {
				io.Copy(dst, f)
			}
			f.Close()
		}
	default:
		httpErr(w, http.StatusBadRequest, "format must be glb, fbx or zip")
	}
}

func (s *Server) handleFCEvents(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !validID(id) {
		httpErr(w, http.StatusBadRequest, "invalid id")
		return
	}
	s.broker.ServeTopic(w, r, id)
}

// publishCharacter feeds both the global /events stream and the per-character
// one the app's progress stepper listens on.
func (s *Server) publishCharacter(event string, c *Character) {
	s.broker.PublishTopic(c.ID, event, c)
}

// fcViewerHTML is the character's 3D page. Same trick as the job viewer: page,
// model and script share an origin, which is what makes it work inside the
// app's WebView on both platforms.
//
// Clips are switched from Flutter through window.fcPlay(name) rather than by
// reloading with a different query — a reload would re-download the GLB every
// time you tap another animation.
const fcViewerHTML = `<!doctype html>
<html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<script type="module" src="/viewer/assets/model-viewer.min.js"></script>
<style>
  html,body{margin:0;height:100%%;background:#14161a;overflow:hidden}
  model-viewer{width:100%%;height:100%%;--poster-color:#14161a}
  #err{position:absolute;inset:0;display:none;place-items:center;color:#ff8a80;
       font:14px -apple-system,system-ui,sans-serif;text-align:center;padding:24px}
</style></head>
<body>
<model-viewer src="%s" alt="%s" camera-controls touch-action="pan-y"
  environment-image="neutral" exposure="1.4" shadow-intensity="0.6"
  camera-orbit="200deg 78deg 130%%" min-field-of-view="20deg"
  interaction-prompt="none" autoplay %s></model-viewer>
<div id="err"></div>
<script>
  const mv = document.querySelector('model-viewer');
  mv.addEventListener('error', e => {
    const d = document.getElementById('err');
    d.style.display = 'grid';
    d.textContent = 'Model se nepodarilo nacist: ' + (e.detail && e.detail.type || 'chyba');
  });
  // Volane z Flutteru pres runJavaScript. Vraci false, kdyz klip v modelu
  // neni - to je signal, ze retarget a knihovna se rozesly.
  window.fcPlay = function (name) {
    if (!mv.availableAnimations.includes(name)) return false;
    mv.animationName = name;
    mv.play();
    return true;
  };
  window.fcClips = () => mv.availableAnimations;
</script>
</body></html>`

// handleFCViewer serves the standalone 3D page for one character.
func (s *Server) handleFCViewer(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	clip := ""
	if v := r.URL.Query().Get("clip"); v != "" && validID(v) {
		clip = fmt.Sprintf("animation-name=%q", v)
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprintf(w, fcViewerHTML,
		fmt.Sprintf("/v1/fc/characters/%s/file/final_glb", c.ID),
		html.EscapeString(c.Name), clip)
}

// --- exports -------------------------------------------------------------

func (s *Server) handleFCExport(w http.ResponseWriter, r *http.Request) {
	c := s.characterOr404(w, r.PathValue("id"))
	if c == nil {
		return
	}
	var body struct {
		Target string `json:"target"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}
	if !validTarget(body.Target) {
		httpErr(w, http.StatusBadRequest, "target must be roblox, luanti or user")
		return
	}
	if c.FinalGLB == "" {
		httpErr(w, http.StatusConflict, "character %s has no final model yet", c.ID)
		return
	}
	e := &Export{CharacterID: c.ID, Target: body.Target, Status: "pending"}
	if err := s.store.InsertExport(e); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	if _, err := s.store.EnqueueStep(c.ID, "char.export."+body.Target); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	s.broker.PublishTopic(c.ID, "export.created", e)
	writeJSON(w, http.StatusAccepted, e)
}

func (s *Server) handleFCGetExport(w http.ResponseWriter, r *http.Request) {
	e, err := s.store.GetExport(r.PathValue("id"))
	if err != nil {
		httpErr(w, http.StatusNotFound, "export not found")
		return
	}
	writeJSON(w, http.StatusOK, e)
}

// --- animation library ---------------------------------------------------

func (s *Server) handleFCListAnimations(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	list, err := s.store.ListAnimations(q.Get("category"), q.Get("tag"), q.Get("license"))
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	writeJSON(w, http.StatusOK, list)
}

// handleFCUpsertAnimation registers a clip. The library is curated by hand
// (§4.3), so this is the ingest side of "download once, describe once".
func (s *Server) handleFCUpsertAnimation(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !validID(id) {
		httpErr(w, http.StatusBadRequest, "invalid animation id")
		return
	}
	var a Animation
	if err := json.NewDecoder(r.Body).Decode(&a); err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}
	a.ID = id
	if a.FBXPath == "" {
		httpErr(w, http.StatusBadRequest, "missing fbx_path")
		return
	}
	if a.License == "" {
		httpErr(w, http.StatusBadRequest, "missing license — exports filter on it")
		return
	}
	if err := s.store.UpsertAnimation(&a); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	writeJSON(w, http.StatusOK, &a)
}

// --- worker --------------------------------------------------------------

// handleFCWorkerClaim hands out one pending step with everything the worker
// needs: paths on the shared volume and the clip list for retarget.py.
func (s *Server) handleFCWorkerClaim(w http.ResponseWriter, r *http.Request) {
	step, err := s.store.ClaimNextStep()
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	if step == nil {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	c, err := s.store.GetCharacter(step.CharacterID)
	if err != nil {
		s.store.FinishStep(step.ID, "failed", "character vanished")
		httpErr(w, http.StatusInternalServerError, "character %s vanished", step.CharacterID)
		return
	}
	anims, _ := s.store.ListCharacterAnimations(c.ID)
	clips := make([]map[string]any, 0, len(anims))
	for _, ca := range anims {
		a, err := s.store.GetAnimation(ca.AnimationID)
		if err != nil {
			continue
		}
		clips = append(clips, map[string]any{
			"id": a.ID, "fbx_path": a.FBXPath, "frames": a.Frames,
			"fps": a.FPS, "loop": a.Loop,
		})
	}
	s.publishCharacter("character.step.started", c)
	writeJSON(w, http.StatusOK, map[string]any{
		"step_id":   step.ID,
		"step":      step.Step,
		"attempt":   step.Attempt,
		"character": c,
		"dir":       s.charDir(c.ID),
		"files":     charFiles,
		"clips":     clips,
	})
}

// handleFCWorkerResult records one step's outcome and, on success, advances
// the pipeline: write artifacts, move the status, queue what comes next.
func (s *Server) handleFCWorkerResult(w http.ResponseWriter, r *http.Request) {
	stepID, err := strconv.ParseInt(r.PathValue("step"), 10, 64)
	if err != nil {
		httpErr(w, http.StatusBadRequest, "invalid step id")
		return
	}
	step, err := s.store.GetStep(stepID)
	if err != nil {
		httpErr(w, http.StatusNotFound, "step %d not found", stepID)
		return
	}
	var res struct {
		Error       string             `json:"error"`
		Artifacts   map[string]any     `json:"artifacts"`
		FrameRanges map[string][]int64 `json:"frame_ranges"`
		ExternalID  string             `json:"external_id"`
		Artifact    string             `json:"artifact_path"`
	}
	if err := json.NewDecoder(r.Body).Decode(&res); err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}

	if res.Error != "" {
		if ok, _ := s.store.FinishStep(step.ID, "failed", res.Error); !ok {
			httpErr(w, http.StatusConflict, "step %d is not running", step.ID)
			return
		}
		s.store.SetCharacterError(step.CharacterID, fmt.Sprintf("%s: %s", step.Step, res.Error))
		s.finishExport(step, "failed", res.Error, "", "")
		c, _ := s.store.GetCharacter(step.CharacterID)
		s.publishCharacter("character.failed", c)
		writeJSON(w, http.StatusOK, map[string]string{"status": "failed"})
		return
	}

	if len(res.Artifacts) > 0 {
		if err := s.store.SetCharacterArtifacts(step.CharacterID, res.Artifacts); err != nil {
			httpErr(w, http.StatusBadRequest, "artifacts: %v", err)
			return
		}
	}
	if len(res.FrameRanges) > 0 {
		ranges := map[string][2]int64{}
		for id, r := range res.FrameRanges {
			if len(r) == 2 {
				ranges[id] = [2]int64{r[0], r[1]}
			}
		}
		if err := s.store.SetFrameRanges(step.CharacterID, ranges); err != nil {
			httpErr(w, http.StatusInternalServerError, "frame ranges: %v", err)
			return
		}
	}
	if ok, _ := s.store.FinishStep(step.ID, "done", ""); !ok {
		httpErr(w, http.StatusConflict, "step %d is not running", step.ID)
		return
	}
	s.store.ClearCharacterError(step.CharacterID)
	s.finishExport(step, "done", "", res.ExternalID, res.Artifact)

	// pipeline krok posune stav a zaradi dalsi; export krok nechava stav byt
	if status := statusAfter(step.Step); status != "" {
		s.store.SetCharacterStatus(step.CharacterID, status)
		if next := nextStep(step.Step); next != "" {
			if _, err := s.store.EnqueueStep(step.CharacterID, next); err != nil {
				httpErr(w, http.StatusInternalServerError, "enqueue %s: %v", next, err)
				return
			}
		} else {
			s.store.SetCharacterStatus(step.CharacterID, "done")
		}
	}
	c, _ := s.store.GetCharacter(step.CharacterID)
	s.publishCharacter("character.updated", c)
	writeJSON(w, http.StatusOK, map[string]any{"status": "ok", "character": c})
}

// finishExport closes the export row a char.export.{target} step belongs to.
func (s *Server) finishExport(step *CharacterStep, status, errMsg, externalID, artifact string) {
	target := strings.TrimPrefix(step.Step, "char.export.")
	if target == step.Step {
		return
	}
	e, err := s.store.PendingExport(step.CharacterID, target)
	if err != nil {
		return
	}
	s.store.SetExportResult(e.ID, status, errMsg, externalID, artifact)
	e, _ = s.store.GetExport(e.ID)
	s.broker.PublishTopic(step.CharacterID, "export.updated", e)
}
