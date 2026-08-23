// Package ugc runs the item factory inlet on Spark: concept image ->
// cleanplate -> textured GLB -> push to the NAS (ugc-api). One worker,
// serialized — img->3D alongside other GPU work is the known power-spike
// crash on the GB10.
package ugc

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

type Config struct {
	Comfy      *Comfy
	NAS        *NAS
	SF3D       *SF3D
	Checkpoint string        // default checkpoint pro koncepty
	Timeout    time.Duration // na jednu ComfyUI stage
	QueueDir   string        // perzistence fronty (prezije restart)
}

type Request struct {
	Prompt     string `json:"prompt"`
	Category   string `json:"category"`
	Style      string `json:"style"`
	Backend    string `json:"backend"` // trellis (default) | sf3d (az bude)
	Collection string `json:"collection"`
	Seed       int64  `json:"seed"`
	RerollOf   string `json:"reroll_of"`
	Checkpoint string `json:"checkpoint"` // volitelny override
}

type Job struct {
	ID        string    `json:"id"`
	Stage     string    `json:"stage"` // queued/concept/cleanplate/mesh/push/done/failed
	Error     string    `json:"error,omitempty"`
	Req       Request   `json:"request"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Pipeline struct {
	cfg  Config
	mu   sync.Mutex
	jobs map[string]*Job
	work chan string
}

func New(cfg Config) *Pipeline {
	p := &Pipeline{cfg: cfg, jobs: map[string]*Job{}, work: make(chan string, 4096)}
	p.restore()
	go p.worker()
	go p.cfg.NAS.RetrySpool()
	return p
}

// normalizeBackend doplni vychozi hodnotu. Musi platit i pro joby obnovene
// z disku - jinak jim zustane prazdny backend a spadnou do TRELLIS vetve
// (presne to se stalo pri prvnim nasazeni SF3D).
func normalizeBackend(b string) string {
	if b == "" {
		// SF3D: ~1,5 s misto ~4 min, low-poly s UV a normalami.
		return "sf3d"
	}
	return b
}

// persist ulozi nedokonceny job na disk. Bez toho restart kontejneru
// (tedy kazdy deploy) zahodi celou frontu - stalo se to a preslo to
// nekolik hodin prace.
func (p *Pipeline) persist(job *Job) {
	if p.cfg.QueueDir == "" {
		return
	}
	os.MkdirAll(p.cfg.QueueDir, 0o755)
	b, err := json.Marshal(job)
	if err != nil {
		return
	}
	os.WriteFile(filepath.Join(p.cfg.QueueDir, job.ID+".json"), b, 0o644)
}

func (p *Pipeline) forget(id string) {
	if p.cfg.QueueDir != "" {
		os.Remove(filepath.Join(p.cfg.QueueDir, id+".json"))
	}
}

// restore vrati do fronty joby, ktere pri predchozim behu nedobehly.
func (p *Pipeline) restore() {
	if p.cfg.QueueDir == "" {
		return
	}
	entries, err := os.ReadDir(p.cfg.QueueDir)
	if err != nil {
		return
	}
	n := 0
	for _, e := range entries {
		if e.IsDir() || filepath.Ext(e.Name()) != ".json" {
			continue
		}
		b, err := os.ReadFile(filepath.Join(p.cfg.QueueDir, e.Name()))
		if err != nil {
			continue
		}
		var job Job
		if json.Unmarshal(b, &job) != nil || job.ID == "" {
			continue
		}
		job.Stage = "queued"
		job.Req.Backend = normalizeBackend(job.Req.Backend)
		p.jobs[job.ID] = &job
		select {
		case p.work <- job.ID:
			n++
		default:
		}
	}
	if n > 0 {
		slog.Info("fronta obnovena po restartu", "jobu", n)
	}
}

func (p *Pipeline) Submit(req Request) (*Job, error) {
	if strings.TrimSpace(req.Prompt) == "" {
		return nil, fmt.Errorf("missing prompt")
	}
	if req.Category == "" {
		return nil, fmt.Errorf("missing category")
	}
	req.Backend = normalizeBackend(req.Backend)
	if req.Backend != "trellis" && req.Backend != "sf3d" {
		return nil, fmt.Errorf("neznamy backend %q (trellis|sf3d)", req.Backend)
	}
	if req.Seed == 0 {
		req.Seed = time.Now().UnixNano() % 2147483647
	}
	job := &Job{
		ID:        fmt.Sprintf("ugc-%d", time.Now().UnixNano()),
		Stage:     "queued",
		Req:       req,
		CreatedAt: time.Now().UTC(),
		UpdatedAt: time.Now().UTC(),
	}
	p.mu.Lock()
	p.jobs[job.ID] = job
	p.mu.Unlock()
	p.persist(job)
	select {
	case p.work <- job.ID:
	default:
		return nil, fmt.Errorf("queue full")
	}
	return job, nil
}

func (p *Pipeline) Get(id string) *Job {
	p.mu.Lock()
	defer p.mu.Unlock()
	if j, ok := p.jobs[id]; ok {
		cp := *j
		return &cp
	}
	return nil
}

func (p *Pipeline) List() []*Job {
	p.mu.Lock()
	defer p.mu.Unlock()
	out := make([]*Job, 0, len(p.jobs))
	for _, j := range p.jobs {
		cp := *j
		out = append(out, &cp)
	}
	return out
}

func (p *Pipeline) setStage(id, stage, errMsg string) {
	p.mu.Lock()
	if j, ok := p.jobs[id]; ok {
		j.Stage = stage
		j.Error = errMsg
		j.UpdatedAt = time.Now().UTC()
	}
	p.mu.Unlock()
}

func (p *Pipeline) worker() {
	for id := range p.work {
		p.run(id)
	}
}

func (p *Pipeline) run(id string) {
	job := p.Get(id)
	if job == nil {
		return
	}
	ctx := context.Background()
	log := slog.With("ugc_job", id)
	started := time.Now()

	fail := func(stage string, err error) {
		log.Error("ugc stage failed", "stage", stage, "err", err)
		p.setStage(id, "failed", fmt.Sprintf("%s: %v", stage, err))
		p.forget(id)
	}

	// 1. koncept
	p.setStage(id, "concept", "")
	checkpoint, product := PickModel(job.Req.Category, job.Req.Checkpoint)
	var pos, neg string
	if product {
		pos, neg = productPrompt(job.Req.Category, job.Req.Prompt, job.Req.Style)
	} else {
		pos, neg = PromptFor(job.Req.Category, job.Req.Style, job.Req.Prompt)
	}
	log.Info("concept", "model", checkpoint, "product_mode", product)
	prefix := "ugc/" + id
	var conceptG map[string]any
	if IsFlux(checkpoint) {
		conceptG = fluxConceptGraph(pos, job.Req.Seed, prefix+"-concept")
	} else {
		conceptG = conceptGraph(checkpoint, pos, neg, job.Req.Seed, prefix+"-concept")
	}
	outs, err := p.cfg.Comfy.Run(ctx, conceptG, p.cfg.Timeout)
	if err != nil {
		fail("concept", err)
		return
	}
	conceptPNG, err := p.firstImage(ctx, outs)
	if err != nil {
		fail("concept-fetch", err)
		return
	}

	// 2. cleanplate (RMBG alfa)
	p.setStage(id, "cleanplate", "")
	inputName := id + "-concept.png"
	if err := p.cfg.Comfy.UploadImage(ctx, inputName, conceptPNG); err != nil {
		fail("cleanplate-upload", err)
		return
	}
	outs, err = p.cfg.Comfy.Run(ctx, cleanplateGraph(inputName, prefix+"-clean"), p.cfg.Timeout)
	if err != nil {
		fail("cleanplate", err)
		return
	}
	cleanPNG, err := p.firstImage(ctx, outs)
	if err != nil {
		fail("cleanplate-fetch", err)
		return
	}

	// 3. mesh - SF3D (rychla draha) nebo TRELLIS (vic detailu)
	p.setStage(id, "mesh", "")
	var glb []byte
	if job.Req.Backend == "sf3d" {
		glb, err = p.cfg.SF3D.Mesh(ctx, cleanPNG)
		if err != nil {
			fail("mesh-sf3d", err)
			return
		}
	} else {
		meshInput := id + "-clean.png"
		if err := p.cfg.Comfy.UploadImage(ctx, meshInput, cleanPNG); err != nil {
			fail("mesh-upload", err)
			return
		}
		outs, err = p.cfg.Comfy.Run(ctx, trellisGraph(meshInput, job.Req.Seed, "3D/"+id), p.cfg.Timeout)
		if err != nil {
			fail("mesh", err)
			return
		}
		glb, err = p.meshFile(ctx, outs, id)
		if err != nil {
			fail("mesh-fetch", err)
			return
		}
	}

	// 4. push na NAS (pri nedostupnosti spool + retry)
	p.setStage(id, "push", "")
	meta := map[string]any{
		"id": id, "prompt": job.Req.Prompt, "category": job.Req.Category,
		"style": job.Req.Style, "backend": job.Req.Backend, "seed": job.Req.Seed,
		"collection": job.Req.Collection, "reroll_of": job.Req.RerollOf,
		"checkpoint": checkpoint, "created_at": job.CreatedAt.Format(time.RFC3339),
	}
	metaJSON, _ := json.Marshal(meta)
	if err := p.cfg.NAS.Push(id, glb, conceptPNG, metaJSON); err != nil {
		log.Warn("NAS push failed, spooled", "err", err)
		p.setStage(id, "done", "spooled: "+err.Error())
	} else {
		p.setStage(id, "done", "")
	}
	p.forget(id)
	log.Info("ugc job done", "took", time.Since(started).Round(time.Second))
}

// firstImage finds the first SaveImage output in history outputs and
// downloads it.
func (p *Pipeline) firstImage(ctx context.Context, outs map[string]any) ([]byte, error) {
	for _, v := range outs {
		nodeOut, _ := v.(map[string]any)
		images, _ := nodeOut["images"].([]any)
		for _, img := range images {
			m, _ := img.(map[string]any)
			fn, _ := m["filename"].(string)
			sub, _ := m["subfolder"].(string)
			kind, _ := m["type"].(string)
			if fn != "" {
				return p.cfg.Comfy.View(ctx, fn, sub, kind)
			}
		}
	}
	return nil, fmt.Errorf("no image in outputs")
}

// meshFile downloads the exported GLB. Trellis2ExportMesh emits no UI
// outputs, so the file is fetched by its deterministic prefix path.
func (p *Pipeline) meshFile(ctx context.Context, outs map[string]any, id string) ([]byte, error) {
	// zkusit UI outputs (kdyby budouci verze nodu zacala hlasit soubory)
	for _, v := range outs {
		nodeOut, _ := v.(map[string]any)
		for _, key := range []string{"mesh", "files", "result"} {
			files, _ := nodeOut[key].([]any)
			for _, f := range files {
				if m, ok := f.(map[string]any); ok {
					if fn, _ := m["filename"].(string); strings.HasSuffix(fn, ".glb") {
						sub, _ := m["subfolder"].(string)
						return p.cfg.Comfy.View(ctx, fn, sub, "output")
					}
				}
			}
		}
	}
	// deterministicka cesta: 3D/{id}_00001_.glb
	return p.cfg.Comfy.View(ctx, id+"_00001_.glb", "3D", "output")
}
