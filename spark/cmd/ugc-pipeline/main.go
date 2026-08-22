// ugc-pipeline je vstup tovarny na Sparku: prompt -> koncept -> cleanplate
// -> texturovany GLB -> push na NAS (ugc-api).
//
// Driv zil jako balicek uvnitr AiStack/gen-queue; osamostatnen pri prechodu
// na monorepo UGCFactory, aby sla cela tovarna nasadit z jednoho mista.
// gen-queue tim zustava tim, cim byl - frontou pro NIM image generation.
package main

import (
	"log/slog"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/lioilsources/UGCFactory/spark/internal/ugc"
)

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func envInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			return n
		}
	}
	return fallback
}

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))

	addr := envOr("UGC_ADDR", ":8092")
	pipe := ugc.New(ugc.Config{
		Comfy:      ugc.NewComfy(envOr("UGC_COMFY_URL", "http://host.docker.internal:8188")),
		NAS:        ugc.NewNAS(envOr("UGC_NAS_URL", "http://192.168.88.88:8095"), envOr("UGC_SPOOL", "/spool")),
		Checkpoint: envOr("UGC_CHECKPOINT", "Illustrious-XL-v2.0.safetensors"),
		Timeout:    time.Duration(envInt("UGC_STAGE_TIMEOUT_SECONDS", 900)) * time.Second,
	})

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"ok","service":"ugc-pipeline"}`)) //nolint:errcheck
	})
	ugc.Register(mux, pipe)

	slog.Info("ugc-pipeline ready", "addr", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		slog.Error("server stopped", "err", err)
		os.Exit(1)
	}
}
