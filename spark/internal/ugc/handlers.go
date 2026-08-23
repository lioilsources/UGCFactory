package ugc

import (
	"encoding/json"
	"net/http"
)

// Register mounts the factory inlet endpoints. Drive je mel gen-queue ve
// svem api balicku; po osamostatneni sedi u pipeline, ktere patri.
func Register(mux *http.ServeMux, pipe *Pipeline) {
	mux.HandleFunc("POST /ugc/generate", func(w http.ResponseWriter, r *http.Request) {
		var req Request
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			jsonError(w, err.Error(), http.StatusBadRequest)
			return
		}
		job, err := pipe.Submit(req)
		if err != nil {
			jsonError(w, err.Error(), http.StatusBadRequest)
			return
		}
		writeJSON(w, http.StatusAccepted, job)
	})
	mux.HandleFunc("GET /ugc/jobs", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, pipe.List())
	})
	// NAS sem posle job po schvaleni v triage, aby se draft prepocital
	// kvalitnejsim backendem. Bezi synchronne - u TRELLISu ~4 min.
	mux.HandleFunc("POST /ugc/remesh/{id}", func(w http.ResponseWriter, r *http.Request) {
		backend := r.URL.Query().Get("backend")
		if backend == "" {
			backend = "trellis"
		}
		if err := pipe.Remesh(r.Context(), r.PathValue("id"), backend); err != nil {
			jsonError(w, err.Error(), http.StatusBadGateway)
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{"status": "remeshed", "backend": backend})
	})
	mux.HandleFunc("GET /ugc/jobs/{id}", func(w http.ResponseWriter, r *http.Request) {
		job := pipe.Get(r.PathValue("id"))
		if job == nil {
			jsonError(w, "job not found", http.StatusNotFound)
			return
		}
		writeJSON(w, http.StatusOK, job)
	})
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func jsonError(w http.ResponseWriter, msg string, code int) {
	writeJSON(w, code, map[string]string{"error": msg})
}
