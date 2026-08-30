package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

// TestRepackKeepsCatalogData: prebaleni po oprave convert.py nesmi zahodit
// jmeno, popisy, cenu ani tagy vyplnene v appce. UpsertItem prepisuje vsechny
// sloupce, takze bez slucovani v pack() by se vratily na vychozi hodnoty.
func TestRepackKeepsCatalogData(t *testing.T) {
	dir := t.TempDir()
	store, err := OpenStore(filepath.Join(dir, "ugc.db"))
	if err != nil {
		t.Fatal(err)
	}
	s := &Server{store: store, broker: NewBroker(), data: dir}

	job := &Job{ID: "kus-1", Status: "converted", Prompt: "ornate samurai helmet",
		Category: "helmet", Collection: "Samurai Neon", Backend: "trellis"}
	if err := store.InsertJob(job); err != nil {
		t.Fatal(err)
	}
	conv := filepath.Join(dir, "converted", job.ID)
	if err := os.MkdirAll(conv, 0o755); err != nil {
		t.Fatal(err)
	}
	for _, f := range []string{"model.fbx", "model_tex.png"} {
		if err := os.WriteFile(filepath.Join(conv, f), []byte("x"), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	if err := s.pack(job); err != nil {
		t.Fatalf("prvni pack: %v", err)
	}

	// Uzivatel vyplni katalog v appce.
	it, err := store.GetItem(job.ID)
	if err != nil {
		t.Fatal(err)
	}
	it.Name = "Kabuto Neon"
	it.DescriptionCS = "Samurajska helma"
	it.PriceRobux = 75
	it.Tags = json.RawMessage(`["samurai","neon"]`)
	if err := store.UpsertItem(it); err != nil {
		t.Fatal(err)
	}

	// Oprava convert.py -> reconvert -> pack znovu.
	job, _ = store.GetJob(job.ID)
	if err := s.pack(job); err != nil {
		t.Fatalf("prebaleni: %v", err)
	}
	got, err := store.GetItem(job.ID)
	if err != nil {
		t.Fatal(err)
	}
	if got.Name != "Kabuto Neon" || got.DescriptionCS != "Samurajska helma" || got.PriceRobux != 75 {
		t.Fatalf("katalogova data se ztratila: %+v", got)
	}
	if string(got.Tags) != `["samurai","neon"]` {
		t.Fatalf("tagy se ztratily: %s", got.Tags)
	}
	// item.json vedle FBX musi nest totez, ne vychozi hodnoty.
	raw, err := os.ReadFile(filepath.Join(dir, "packed", job.ID, "item.json"))
	if err != nil {
		t.Fatal(err)
	}
	var onDisk map[string]any
	if err := json.Unmarshal(raw, &onDisk); err != nil {
		t.Fatal(err)
	}
	if onDisk["name"] != "Kabuto Neon" || onDisk["price_robux"].(float64) != 75 {
		t.Fatalf("item.json ma vychozi hodnoty: %s", raw)
	}
	if st, _ := store.GetJob(job.ID); st.Status != "packed" {
		t.Fatalf("job po prebaleni ma status %q", st.Status)
	}
}
