package ugc

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// SF3D je klient standalone sluzby na Sparku (sf3d-server/server.py).
// Na rozdil od TRELLISu to neni ComfyUI node - model bezi ve vlastnim
// procesu a drzi vahy v pameti, takze jeden mesh trva ~1,5 s misto ~4 min.
// Vraci low-poly GLB s UV, normalami a odstranenym nasvicenim, coz je
// presne to, co Roblox chce v barevne mape.
type SF3D struct {
	URL    string
	Client *http.Client
}

func NewSF3D(url string) *SF3D {
	return &SF3D{URL: url, Client: &http.Client{Timeout: 5 * time.Minute}}
}

func (s *SF3D) Available(ctx context.Context) bool {
	req, err := http.NewRequestWithContext(ctx, "GET", s.URL+"/health", nil)
	if err != nil {
		return false
	}
	resp, err := (&http.Client{Timeout: 5 * time.Second}).Do(req)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == http.StatusOK
}

// Mesh posle cleanplate PNG a vrati GLB.
func (s *SF3D) Mesh(ctx context.Context, png []byte) ([]byte, error) {
	req, err := http.NewRequestWithContext(ctx, "POST", s.URL+"/generate", bytes.NewReader(png))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "image/png")
	resp, err := s.Client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		var e struct {
			Error string `json:"error"`
		}
		if json.Unmarshal(body, &e) == nil && e.Error != "" {
			return nil, fmt.Errorf("sf3d: %s", e.Error)
		}
		return nil, fmt.Errorf("sf3d: HTTP %d", resp.StatusCode)
	}
	if len(body) < 12 || string(body[0:4]) != "glTF" {
		return nil, fmt.Errorf("sf3d: odpoved neni GLB (%d B)", len(body))
	}
	return body, nil
}
