// ugc-api is the heart of the UGC factory on the NAS (see UGC_NAS_PLAN.md):
// Spark pushes generated GLBs here, the Flutter app triages them, the blender
// worker converts approved ones, and the Mac pulls packed zips for Studio.
//
// Auth is Cloudflare Access at the edge (tunnel connector enforces the JWT,
// same pattern as finetune.ol1n.com); on the LAN the API is open.
package main

import (
	"archive/zip"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

const maxUpload = 256 << 20 // multipart strop; GLB + preview jsou jednotky MB

type Server struct {
	store  *Store
	broker *Broker
	data   string // /data
	spark  sparkConfig
}

// sparkConfig is the reroll/generate callback into ImageStudio on Spark.
type sparkConfig struct {
	GenerateURL  string // e.g. https://imagestudio.ol1n.com/ugc/generate
	ClientID     string // CF Access service token pro Spark
	ClientSecret string
}

func main() {
	addr := envOr("UGC_ADDR", ":8095")
	dataDir := envOr("UGC_DATA", "/data")
	for _, d := range []string{"incoming", "converted", "packed", "rejected", "jobs"} {
		if err := os.MkdirAll(filepath.Join(dataDir, d), 0o755); err != nil {
			log.Fatal(err)
		}
	}
	store, err := OpenStore(filepath.Join(dataDir, "ugc.db"))
	if err != nil {
		log.Fatal(err)
	}
	s := &Server{
		store:  store,
		broker: NewBroker(),
		data:   dataDir,
		spark: sparkConfig{
			GenerateURL:  os.Getenv("SPARK_GENERATE_URL"),
			ClientID:     os.Getenv("SPARK_CF_CLIENT_ID"),
			ClientSecret: os.Getenv("SPARK_CF_CLIENT_SECRET"),
		},
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", s.handleHealthz)
	mux.HandleFunc("POST /jobs", s.handleCreateJob)
	mux.HandleFunc("GET /jobs", s.handleListJobs)
	mux.HandleFunc("GET /jobs/{id}", s.handleGetJob)
	mux.HandleFunc("GET /jobs/{id}/preview", s.handlePreview)
	mux.HandleFunc("GET /jobs/{id}/glb", s.handleGLB)
	mux.HandleFunc("POST /jobs/{id}/approve", s.handleApprove)
	mux.HandleFunc("POST /jobs/{id}/reject", s.handleReject)
	mux.HandleFunc("POST /jobs/{id}/reconvert", s.handleReconvert)
	mux.HandleFunc("POST /jobs/{id}/reroll", s.handleReroll)
	mux.HandleFunc("POST /generate", s.handleGenerate)
	mux.HandleFunc("GET /items", s.handleListItems)
	mux.HandleFunc("PATCH /items/{id}", s.handlePatchItem)
	mux.HandleFunc("GET /packed/{id}/download", s.handleDownload)
	mux.Handle("GET /events", s.broker)
	// worker-only endpointy: v compose siti neverejne, ven je tunnel nepublikuje
	mux.HandleFunc("POST /worker/claim", s.handleWorkerClaim)
	mux.HandleFunc("POST /worker/result/{id}", s.handleWorkerResult)

	log.Printf("ugc-api listening on %s, data in %s", addr, dataDir)
	log.Fatal(http.ListenAndServe(addr, logRequests(mux)))
}

func envOr(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		if r.URL.Path != "/healthz" {
			log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start).Round(time.Millisecond))
		}
	})
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(v)
}

func httpErr(w http.ResponseWriter, code int, format string, a ...any) {
	writeJSON(w, code, map[string]string{"error": fmt.Sprintf(format, a...)})
}

func (s *Server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	if err := s.store.Ping(); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

// handleCreateJob accepts Spark's push: multipart with glb, preview and meta.
func (s *Server) handleCreateJob(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(maxUpload); err != nil {
		httpErr(w, http.StatusBadRequest, "multipart: %v", err)
		return
	}
	metaStr := r.FormValue("meta")
	if metaStr == "" {
		httpErr(w, http.StatusBadRequest, "missing meta field")
		return
	}
	var meta struct {
		ID         string `json:"id"`
		Prompt     string `json:"prompt"`
		Category   string `json:"category"`
		Style      string `json:"style"`
		Backend    string `json:"backend"`
		Seed       int64  `json:"seed"`
		Collection string `json:"collection"`
	}
	if err := json.Unmarshal([]byte(metaStr), &meta); err != nil {
		httpErr(w, http.StatusBadRequest, "meta: %v", err)
		return
	}
	if meta.ID == "" {
		meta.ID = fmt.Sprintf("job-%d", time.Now().UnixNano())
	}
	if !validID(meta.ID) {
		httpErr(w, http.StatusBadRequest, "invalid id %q", meta.ID)
		return
	}
	if meta.Category == "" {
		httpErr(w, http.StatusBadRequest, "missing category")
		return
	}

	dir := filepath.Join(s.data, "incoming", meta.ID)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	if err := saveFormFile(r, "glb", filepath.Join(dir, "model.glb")); err != nil {
		httpErr(w, http.StatusBadRequest, "glb: %v", err)
		return
	}
	// preview je volitelny (concept-only joby appka triaguje jen podle nej)
	_ = saveFormFile(r, "preview", filepath.Join(dir, "preview.png"))

	job := &Job{
		ID: meta.ID, Status: "new", Prompt: meta.Prompt, Category: meta.Category,
		Style: meta.Style, Backend: meta.Backend, Seed: meta.Seed,
		Collection: meta.Collection, Meta: json.RawMessage(metaStr),
	}
	if err := s.store.InsertJob(job); err != nil {
		httpErr(w, http.StatusConflict, "insert: %v", err)
		return
	}
	s.broker.Publish("job.created", job)
	writeJSON(w, http.StatusCreated, job)
}

func saveFormFile(r *http.Request, field, dst string) error {
	f, _, err := r.FormFile(field)
	if err != nil {
		return err
	}
	defer f.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, f)
	return err
}

func validID(id string) bool {
	if len(id) == 0 || len(id) > 128 {
		return false
	}
	for _, r := range id {
		ok := r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || r == '-' || r == '_'
		if !ok {
			return false
		}
	}
	return true
}

func (s *Server) handleListJobs(w http.ResponseWriter, r *http.Request) {
	limit := 200
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 1000 {
			limit = n
		}
	}
	jobs, err := s.store.ListJobs(r.URL.Query().Get("status"), limit)
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	writeJSON(w, http.StatusOK, jobs)
}

func (s *Server) jobOr404(w http.ResponseWriter, id string) *Job {
	if !validID(id) {
		httpErr(w, http.StatusBadRequest, "invalid id")
		return nil
	}
	job, err := s.store.GetJob(id)
	if err != nil {
		httpErr(w, http.StatusNotFound, "job %s not found", id)
		return nil
	}
	return job
}

func (s *Server) handleGetJob(w http.ResponseWriter, r *http.Request) {
	if job := s.jobOr404(w, r.PathValue("id")); job != nil {
		writeJSON(w, http.StatusOK, job)
	}
}

func (s *Server) serveJobFile(w http.ResponseWriter, r *http.Request, name string) {
	job := s.jobOr404(w, r.PathValue("id"))
	if job == nil {
		return
	}
	http.ServeFile(w, r, filepath.Join(s.data, "incoming", job.ID, name))
}

func (s *Server) handlePreview(w http.ResponseWriter, r *http.Request) {
	s.serveJobFile(w, r, "preview.png")
}

func (s *Server) handleGLB(w http.ResponseWriter, r *http.Request) {
	s.serveJobFile(w, r, "model.glb")
}

// handleApprove is stage-aware: a new job goes to the converter, a converted
// one gets packed for Studio.
func (s *Server) handleApprove(w http.ResponseWriter, r *http.Request) {
	job := s.jobOr404(w, r.PathValue("id"))
	if job == nil {
		return
	}
	switch job.Status {
	case "new", "failed":
		// failed -> approved je retry konverze (napr. po oprave convert.py)
		if ok, err := s.store.SetJobStatus(job.ID, "approved", "new", "failed"); err != nil || !ok {
			httpErr(w, http.StatusConflict, "cannot approve: %v", err)
			return
		}
	case "converted":
		if err := s.pack(job); err != nil {
			httpErr(w, http.StatusInternalServerError, "pack: %v", err)
			return
		}
	default:
		httpErr(w, http.StatusConflict, "cannot approve job in status %q", job.Status)
		return
	}
	job, _ = s.store.GetJob(job.ID)
	s.broker.Publish("job.updated", job)
	writeJSON(w, http.StatusOK, job)
}

// handleReconvert sends a converted-or-failed job through the worker again —
// the recovery path after a convert.py fix.
func (s *Server) handleReconvert(w http.ResponseWriter, r *http.Request) {
	job := s.jobOr404(w, r.PathValue("id"))
	if job == nil {
		return
	}
	if ok, err := s.store.SetJobStatus(job.ID, "approved", "converted", "failed"); err != nil || !ok {
		httpErr(w, http.StatusConflict, "cannot reconvert from %q: %v", job.Status, err)
		return
	}
	job, _ = s.store.GetJob(job.ID)
	s.broker.Publish("job.updated", job)
	writeJSON(w, http.StatusOK, job)
}

func (s *Server) handleReject(w http.ResponseWriter, r *http.Request) {
	job := s.jobOr404(w, r.PathValue("id"))
	if job == nil {
		return
	}
	if ok, err := s.store.SetJobStatus(job.ID, "rejected", "new", "converted", "failed"); err != nil || !ok {
		httpErr(w, http.StatusConflict, "cannot reject from %q: %v", job.Status, err)
		return
	}
	// presun do rejected/ - drzime 30 dni pro pripadny undo, pak cron smaze
	src := filepath.Join(s.data, "incoming", job.ID)
	if _, err := os.Stat(src); err == nil {
		os.Rename(src, filepath.Join(s.data, "rejected", job.ID))
	}
	job, _ = s.store.GetJob(job.ID)
	s.broker.Publish("job.updated", job)
	writeJSON(w, http.StatusOK, job)
}

// handleReroll asks Spark's ImageStudio for a new roll of the same prompt.
func (s *Server) handleReroll(w http.ResponseWriter, r *http.Request) {
	job := s.jobOr404(w, r.PathValue("id"))
	if job == nil {
		return
	}
	if s.spark.GenerateURL == "" {
		httpErr(w, http.StatusServiceUnavailable, "SPARK_GENERATE_URL not configured")
		return
	}
	payload, _ := json.Marshal(map[string]any{
		"prompt": job.Prompt, "category": job.Category, "style": job.Style,
		"backend": job.Backend, "collection": job.Collection, "reroll_of": job.ID,
	})
	if err := s.callSpark(payload); err != nil {
		httpErr(w, http.StatusBadGateway, "spark: %v", err)
		return
	}
	s.store.SetJobStatus(job.ID, "rerolled", "new")
	job, _ = s.store.GetJob(job.ID)
	s.broker.Publish("job.updated", job)
	writeJSON(w, http.StatusOK, job)
}

// handleGenerate proxies the app's batch composer to Spark - the app talks
// only to ugc.ol1n.com (one API, one auth).
func (s *Server) handleGenerate(w http.ResponseWriter, r *http.Request) {
	if s.spark.GenerateURL == "" {
		httpErr(w, http.StatusServiceUnavailable, "SPARK_GENERATE_URL not configured")
		return
	}
	body, err := io.ReadAll(io.LimitReader(r.Body, 1<<20))
	if err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}
	if err := s.callSpark(body); err != nil {
		httpErr(w, http.StatusBadGateway, "spark: %v", err)
		return
	}
	writeJSON(w, http.StatusAccepted, map[string]string{"status": "queued"})
}

func (s *Server) callSpark(payload []byte) error {
	req, err := http.NewRequest("POST", s.spark.GenerateURL, strings.NewReader(string(payload)))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	if s.spark.ClientID != "" {
		req.Header.Set("CF-Access-Client-Id", s.spark.ClientID)
		req.Header.Set("CF-Access-Client-Secret", s.spark.ClientSecret)
	}
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, b)
	}
	return nil
}

// --- worker endpoints ----------------------------------------------------

// handleWorkerClaim hands the blender worker one approved job. Files travel
// on the shared /data volume; the response is just the job description.
func (s *Server) handleWorkerClaim(w http.ResponseWriter, r *http.Request) {
	job, err := s.store.ClaimNextApproved()
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	if job == nil {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	s.broker.Publish("job.updated", job)
	writeJSON(w, http.StatusOK, job)
}

func (s *Server) handleWorkerResult(w http.ResponseWriter, r *http.Request) {
	job := s.jobOr404(w, r.PathValue("id"))
	if job == nil {
		return
	}
	var res struct {
		Verdict string          `json:"verdict"`
		Error   string          `json:"error"`
		Report  json.RawMessage `json:"report"`
	}
	if err := json.NewDecoder(r.Body).Decode(&res); err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}
	if err := s.store.SetJobResult(job.ID, res.Verdict, res.Error, res.Report); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	job, _ = s.store.GetJob(job.ID)
	s.broker.Publish("job.updated", job)
	writeJSON(w, http.StatusOK, job)
}

// --- pack ---------------------------------------------------------------

// pack turns a converted job into the Studio-ready bundle in packed/:
// {name}.fbx + {name}_tex.png + item.json, plus an item row for the catalog.
func (s *Server) pack(job *Job) error {
	conv := filepath.Join(s.data, "converted", job.ID)
	fbx := filepath.Join(conv, "model.fbx")
	tex := filepath.Join(conv, "model_tex.png")
	if _, err := os.Stat(fbx); err != nil {
		return fmt.Errorf("converted fbx missing: %w", err)
	}
	name := safeName(job.Prompt, job.ID)
	dst := filepath.Join(s.data, "packed", job.ID)
	if err := os.MkdirAll(dst, 0o755); err != nil {
		return err
	}
	if err := copyFile(fbx, filepath.Join(dst, name+".fbx")); err != nil {
		return err
	}
	if _, err := os.Stat(tex); err == nil {
		if err := copyFile(tex, filepath.Join(dst, name+"_tex.png")); err != nil {
			return err
		}
	}
	item := &Item{ID: job.ID, Name: name, Category: job.Category, Collection: job.Collection, State: "packed"}
	itemJSON, _ := json.MarshalIndent(map[string]any{
		"name": name, "description_cs": "", "description_en": "",
		"category": job.Category, "price_robux": 0, "tags": []string{},
		"collection": job.Collection, "limited": map[string]any{"enabled": false},
	}, "", "  ")
	if err := os.WriteFile(filepath.Join(dst, "item.json"), append(itemJSON, '\n'), 0o644); err != nil {
		return err
	}
	if err := s.store.UpsertItem(item); err != nil {
		return err
	}
	if ok, err := s.store.SetJobStatus(job.ID, "packed", "converted"); err != nil || !ok {
		return errors.New("job moved during pack")
	}
	s.broker.Publish("item.created", item)
	return nil
}

func safeName(prompt, fallback string) string {
	words := strings.Fields(strings.ToLower(prompt))
	if len(words) > 4 {
		words = words[:4]
	}
	name := strings.Join(words, "-")
	var b strings.Builder
	for _, r := range name {
		if r >= 'a' && r <= 'z' || r >= '0' && r <= '9' || r == '-' {
			b.WriteRune(r)
		}
	}
	if b.Len() < 3 {
		return fallback
	}
	return b.String()
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, in)
	return err
}

// --- items --------------------------------------------------------------

func (s *Server) handleListItems(w http.ResponseWriter, r *http.Request) {
	items, err := s.store.ListItems()
	if err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	writeJSON(w, http.StatusOK, items)
}

func (s *Server) handlePatchItem(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	it, err := s.store.GetItem(id)
	if err != nil {
		httpErr(w, http.StatusNotFound, "item %s not found", id)
		return
	}
	var patch map[string]json.RawMessage
	if err := json.NewDecoder(r.Body).Decode(&patch); err != nil {
		httpErr(w, http.StatusBadRequest, "%v", err)
		return
	}
	apply := func(key string, dst any) {
		if raw, ok := patch[key]; ok {
			json.Unmarshal(raw, dst)
		}
	}
	apply("name", &it.Name)
	apply("description_cs", &it.DescriptionCS)
	apply("description_en", &it.DescriptionEN)
	apply("price_robux", &it.PriceRobux)
	apply("collection", &it.Collection)
	apply("state", &it.State)
	if raw, ok := patch["tags"]; ok {
		it.Tags = raw
	}
	if raw, ok := patch["limited"]; ok {
		it.Limited = raw
	}
	if err := s.store.UpsertItem(it); err != nil {
		httpErr(w, http.StatusInternalServerError, "%v", err)
		return
	}
	s.broker.Publish("item.updated", it)
	writeJSON(w, http.StatusOK, it)
}

// handleDownload streams the packed bundle as one zip for the Mac.
func (s *Server) handleDownload(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !validID(id) {
		httpErr(w, http.StatusBadRequest, "invalid id")
		return
	}
	dir := filepath.Join(s.data, "packed", id)
	entries, err := os.ReadDir(dir)
	if err != nil || len(entries) == 0 {
		httpErr(w, http.StatusNotFound, "no packed bundle for %s", id)
		return
	}
	w.Header().Set("Content-Type", "application/zip")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%q", id+".zip"))
	zw := zip.NewWriter(w)
	defer zw.Close()
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		f, err := os.Open(filepath.Join(dir, e.Name()))
		if err != nil {
			return
		}
		dst, err := zw.Create(e.Name())
		if err == nil {
			io.Copy(dst, f)
		}
		f.Close()
	}
}
