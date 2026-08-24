package ugc

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

// NAS pushes finished items to ugc-api on JODA. When the NAS is down the
// bundle lands in the spool directory and a background loop retries — Spark
// holds no state beyond that (the NAS is the single source of truth).
type NAS struct {
	URL      string // http://192.168.88.88:8095
	SpoolDir string
	Client   *http.Client
}

func NewNAS(url, spool string) *NAS {
	os.MkdirAll(spool, 0o755)
	return &NAS{URL: url, SpoolDir: spool, Client: &http.Client{Timeout: 120 * time.Second}}
}

func (n *NAS) Push(id string, glb, preview, meta []byte) error {
	if err := n.post(id, glb, preview, meta); err != nil {
		n.spool(id, glb, preview, meta)
		return err
	}
	return nil
}

// errPermanent oznacuje odpoved, kterou opakovani nespravi - payload uz
// platny nebude.
type errPermanent struct{ error }

func (n *NAS) post(id string, glb, preview, meta []byte) error {
	var buf bytes.Buffer
	mw := multipart.NewWriter(&buf)
	fw, _ := mw.CreateFormFile("glb", id+".glb")
	fw.Write(glb)
	if len(preview) > 0 {
		pw, _ := mw.CreateFormFile("preview", id+".png")
		pw.Write(preview)
	}
	mw.WriteField("meta", string(meta))
	mw.Close()

	req, err := http.NewRequest("POST", n.URL+"/jobs", &buf)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", mw.FormDataContentType())
	resp, err := n.Client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 1024))
		err := fmt.Errorf("NAS HTTP %d: %s", resp.StatusCode, b)
		if resp.StatusCode < 500 {
			return errPermanent{err}
		}
		return err
	}
	return nil
}

// repairMeta doplni chybejici pole z NAS zaznamu. Spool si drzi meta.json
// presne tak, jak ho zapsala binarka v dobe pushe - kdyz se pozdeji prida
// povinne pole, stary zaznam uz platny nebude a retry smycka na nem tluce
// donekonecna (belt bag ugc-1787470784926973388 tak jel 20 hodin po peti
// minutach). NAS ma job v DB vcetne kategorie, takze je z ceho doplnit.
func (n *NAS) repairMeta(id string, meta []byte) ([]byte, bool) {
	var m map[string]any
	if json.Unmarshal(meta, &m) != nil {
		return meta, false
	}
	if s, _ := m["category"].(string); s != "" {
		return meta, false
	}
	resp, err := n.Client.Get(n.URL + "/jobs/" + id)
	if err != nil {
		return meta, false
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return meta, false
	}
	var job struct {
		Category string `json:"category"`
	}
	if json.NewDecoder(resp.Body).Decode(&job) != nil || job.Category == "" {
		return meta, false
	}
	m["category"] = job.Category
	fixed, err := json.Marshal(m)
	if err != nil {
		return meta, false
	}
	return fixed, true
}

func (n *NAS) spool(id string, glb, preview, meta []byte) {
	dir := filepath.Join(n.SpoolDir, id)
	os.MkdirAll(dir, 0o755)
	os.WriteFile(filepath.Join(dir, "model.glb"), glb, 0o644)
	if len(preview) > 0 {
		os.WriteFile(filepath.Join(dir, "preview.png"), preview, 0o644)
	}
	os.WriteFile(filepath.Join(dir, "meta.json"), meta, 0o644)
}

// RetrySpool re-pushes spooled bundles every 5 minutes until they land.
func (n *NAS) RetrySpool() {
	for {
		time.Sleep(5 * time.Minute)
		entries, err := os.ReadDir(n.SpoolDir)
		if err != nil {
			continue
		}
		for _, e := range entries {
			if !e.IsDir() {
				continue
			}
			id := e.Name()
			if id == "queue" || id == "failed" {
				continue // sluzebni adresare, ne joby
			}
			dir := filepath.Join(n.SpoolDir, id)
			glb, err1 := os.ReadFile(filepath.Join(dir, "model.glb"))
			meta, err2 := os.ReadFile(filepath.Join(dir, "meta.json"))
			if err1 != nil || err2 != nil {
				continue
			}
			preview, _ := os.ReadFile(filepath.Join(dir, "preview.png"))
			err := n.post(id, glb, preview, meta)
			if _, bad := err.(errPermanent); bad {
				if fixed, ok := n.repairMeta(id, meta); ok {
					os.WriteFile(filepath.Join(dir, "meta.json"), fixed, 0o644)
					slog.Info("spool meta doplnena z NAS", "id", id)
					err = n.post(id, glb, preview, fixed)
				}
			}
			if err != nil {
				if _, bad := err.(errPermanent); bad {
					// Dal uz to nema smysl zkouset. Do karanteny, at je to
					// videt jednou a ne kazdych pet minut navzdy.
					q := filepath.Join(n.SpoolDir, "failed")
					os.MkdirAll(q, 0o755)
					os.Rename(dir, filepath.Join(q, id))
					slog.Error("spool zaznam neopravitelny, karantena", "id", id, "err", err)
					continue
				}
				slog.Warn("spool retry failed", "id", id, "err", err)
				continue
			}
			os.RemoveAll(dir)
			slog.Info("spooled job delivered", "id", id)
		}
	}
}
