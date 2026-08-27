package main

import (
	"database/sql"
	"path/filepath"
	"testing"
)

// TestSymmetryRoundTrip: symetrie musi prezit cestu insert -> claim, protoze
// worker ji cte prave z jobu vracenoho pri /worker/claim.
func TestSymmetryRoundTrip(t *testing.T) {
	s, err := OpenStore(filepath.Join(t.TempDir(), "ugc.db"))
	if err != nil {
		t.Fatal(err)
	}
	if err := s.InsertJob(&Job{ID: "cake-1", Category: "hat", Symmetry: "radial"}); err != nil {
		t.Fatal(err)
	}
	if err := s.InsertJob(&Job{ID: "plain-1", Category: "hat"}); err != nil {
		t.Fatal(err)
	}
	if _, err := s.SetJobStatus("cake-1", "approved", "new"); err != nil {
		t.Fatal(err)
	}
	job, err := s.ClaimNextApproved()
	if err != nil || job == nil {
		t.Fatalf("claim: %v (job=%v)", err, job)
	}
	if job.ID != "cake-1" || job.Symmetry != "radial" {
		t.Fatalf("claim vratil %+v, cekano cake-1/radial", job)
	}
	if plain, err := s.GetJob("plain-1"); err != nil || plain.Symmetry != "" {
		t.Fatalf("job bez symetrie: %+v (%v)", plain, err)
	}
	if err := s.SetJobSymmetry("plain-1", "radial"); err != nil {
		t.Fatal(err)
	}
	if plain, _ := s.GetJob("plain-1"); plain.Symmetry != "radial" {
		t.Fatalf("SetJobSymmetry neulozilo: %+v", plain)
	}
}

// TestMigrateAddsSymmetryToOldDB: na NASu uz DB existuje a drzi ostrou frontu.
// Kdyby ALTER selhal, ugc-api pri startu spadne a tovarna stoji.
func TestMigrateAddsSymmetryToOldDB(t *testing.T) {
	path := filepath.Join(t.TempDir(), "ugc.db")
	old, err := sql.Open("sqlite", path)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := old.Exec(`CREATE TABLE jobs (
	  id TEXT PRIMARY KEY, status TEXT NOT NULL, prompt TEXT DEFAULT '',
	  category TEXT NOT NULL DEFAULT '', style TEXT DEFAULT '', backend TEXT DEFAULT '',
	  seed INTEGER DEFAULT 0, collection TEXT DEFAULT '', verdict TEXT DEFAULT '',
	  error TEXT DEFAULT '', report TEXT DEFAULT '', meta TEXT DEFAULT '',
	  created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
	INSERT INTO jobs (id,status,created_at,updated_at) VALUES ('stary','new','x','y');`); err != nil {
		t.Fatal(err)
	}
	old.Close()

	s, err := OpenStore(path)
	if err != nil {
		t.Fatalf("migrace stare DB: %v", err)
	}
	job, err := s.GetJob("stary")
	if err != nil {
		t.Fatalf("stary job po migraci necitelny: %v", err)
	}
	if job.Symmetry != "" {
		t.Fatalf("cekana prazdna symetrie, je %q", job.Symmetry)
	}
	// Druhy start uz sloupec najde - ALTER musi projit i podruhe.
	if _, err := OpenStore(path); err != nil {
		t.Fatalf("opakovana migrace: %v", err)
	}
}
