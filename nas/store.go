package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	_ "modernc.org/sqlite"
)

// Job is one item travelling through the factory:
//
//	new → approved → converting → converted (PASS/WARN/FAIL) → packed
//	  ↘ rejected                                    ↘ rejected
//	  ↘ reroll (bounces back to Spark, terminal here)
type Job struct {
	ID         string          `json:"id"`
	Status     string          `json:"status"`
	Prompt     string          `json:"prompt,omitempty"`
	Category   string          `json:"category"`
	Style      string          `json:"style,omitempty"`
	Backend    string          `json:"backend,omitempty"`
	Seed       int64           `json:"seed,omitempty"`
	Collection string          `json:"collection,omitempty"`
	Verdict    string          `json:"verdict,omitempty"` // PASS/WARN/FAIL po konverzi
	Error      string          `json:"error,omitempty"`
	Report     json.RawMessage `json:"report,omitempty"` // validate report z convert.py
	Meta       json.RawMessage `json:"meta,omitempty"`   // syrovy meta JSON ze Sparku
	CreatedAt  time.Time       `json:"created_at"`
	UpdatedAt  time.Time       `json:"updated_at"`
}

// Item is catalog metadata of a packed job, edited from the app.
type Item struct {
	ID            string          `json:"id"` // = job id
	Name          string          `json:"name"`
	DescriptionCS string          `json:"description_cs,omitempty"`
	DescriptionEN string          `json:"description_en,omitempty"`
	Category      string          `json:"category"`
	PriceRobux    int64           `json:"price_robux,omitempty"`
	Tags          json.RawMessage `json:"tags,omitempty"`
	Collection    string          `json:"collection,omitempty"`
	Limited       json.RawMessage `json:"limited,omitempty"`
	State         string          `json:"state"` // packed/uploaded/moderation/approved/onsale
	CreatedAt     time.Time       `json:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at"`
}

type Store struct{ db *sql.DB }

func OpenStore(path string) (*Store, error) {
	db, err := sql.Open("sqlite", path+"?_pragma=journal_mode(WAL)&_pragma=busy_timeout(5000)&_pragma=foreign_keys(1)")
	if err != nil {
		return nil, err
	}
	// SQLite: jeden zapisovac; api je jediny proces nad DB (worker jde pres API).
	db.SetMaxOpenConns(1)
	s := &Store{db: db}
	return s, s.migrate()
}

func (s *Store) migrate() error {
	_, err := s.db.Exec(`
CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY, status TEXT NOT NULL, prompt TEXT DEFAULT '',
  category TEXT NOT NULL DEFAULT '', style TEXT DEFAULT '', backend TEXT DEFAULT '',
  seed INTEGER DEFAULT 0, collection TEXT DEFAULT '', verdict TEXT DEFAULT '',
  error TEXT DEFAULT '', report TEXT DEFAULT '', meta TEXT DEFAULT '',
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS jobs_status ON jobs(status);
CREATE TABLE IF NOT EXISTS items (
  id TEXT PRIMARY KEY REFERENCES jobs(id), name TEXT NOT NULL DEFAULT '',
  description_cs TEXT DEFAULT '', description_en TEXT DEFAULT '',
  category TEXT DEFAULT '', price_robux INTEGER DEFAULT 0,
  tags TEXT DEFAULT '', collection TEXT DEFAULT '', limited TEXT DEFAULT '',
  state TEXT NOT NULL DEFAULT 'packed',
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);`)
	return err
}

const timeFmt = time.RFC3339

func (s *Store) InsertJob(j *Job) error {
	now := time.Now().UTC()
	j.CreatedAt, j.UpdatedAt = now, now
	if j.Status == "" {
		j.Status = "new"
	}
	_, err := s.db.Exec(`INSERT INTO jobs
		(id,status,prompt,category,style,backend,seed,collection,verdict,error,report,meta,created_at,updated_at)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
		j.ID, j.Status, j.Prompt, j.Category, j.Style, j.Backend, j.Seed, j.Collection,
		j.Verdict, j.Error, string(j.Report), string(j.Meta),
		j.CreatedAt.Format(timeFmt), j.UpdatedAt.Format(timeFmt))
	return err
}

func scanJob(row interface{ Scan(...any) error }) (*Job, error) {
	var j Job
	var report, meta, created, updated string
	if err := row.Scan(&j.ID, &j.Status, &j.Prompt, &j.Category, &j.Style, &j.Backend,
		&j.Seed, &j.Collection, &j.Verdict, &j.Error, &report, &meta, &created, &updated); err != nil {
		return nil, err
	}
	if report != "" {
		j.Report = json.RawMessage(report)
	}
	if meta != "" {
		j.Meta = json.RawMessage(meta)
	}
	j.CreatedAt, _ = time.Parse(timeFmt, created)
	j.UpdatedAt, _ = time.Parse(timeFmt, updated)
	return &j, nil
}

const jobCols = "id,status,prompt,category,style,backend,seed,collection,verdict,error,report,meta,created_at,updated_at"

func (s *Store) GetJob(id string) (*Job, error) {
	return scanJob(s.db.QueryRow("SELECT "+jobCols+" FROM jobs WHERE id = ?", id))
}

func (s *Store) ListJobs(status string, limit int) ([]*Job, error) {
	q := "SELECT " + jobCols + " FROM jobs"
	var args []any
	if status != "" {
		q += " WHERE status = ?"
		args = append(args, status)
	}
	q += " ORDER BY created_at DESC LIMIT ?"
	args = append(args, limit)
	rows, err := s.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	jobs := []*Job{}
	for rows.Next() {
		j, err := scanJob(rows)
		if err != nil {
			return nil, err
		}
		jobs = append(jobs, j)
	}
	return jobs, rows.Err()
}

// SetJobStatus moves a job to next when its current status is one of from —
// the compare-and-swap that keeps two workers from claiming the same job.
func (s *Store) SetJobStatus(id, next string, from ...string) (bool, error) {
	q := "UPDATE jobs SET status = ?, updated_at = ? WHERE id = ?"
	args := []any{next, time.Now().UTC().Format(timeFmt), id}
	if len(from) > 0 {
		q += " AND status IN (?" + repeat(",?", len(from)-1) + ")"
		for _, f := range from {
			args = append(args, f)
		}
	}
	res, err := s.db.Exec(q, args...)
	if err != nil {
		return false, err
	}
	n, _ := res.RowsAffected()
	return n > 0, nil
}

func repeat(s string, n int) (out string) {
	for i := 0; i < n; i++ {
		out += s
	}
	return
}

// ClaimNextApproved atomically hands one approved job to the worker.
func (s *Store) ClaimNextApproved() (*Job, error) {
	var id string
	err := s.db.QueryRow(`UPDATE jobs SET status='converting', updated_at=?
		WHERE id = (SELECT id FROM jobs WHERE status='approved' ORDER BY created_at LIMIT 1)
		RETURNING id`, time.Now().UTC().Format(timeFmt)).Scan(&id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return s.GetJob(id)
}

func (s *Store) SetJobResult(id, verdict, errMsg string, report json.RawMessage) error {
	status := "converted"
	if errMsg != "" {
		status = "failed"
	}
	_, err := s.db.Exec(`UPDATE jobs SET status=?, verdict=?, error=?, report=?, updated_at=? WHERE id=?`,
		status, verdict, errMsg, string(report), time.Now().UTC().Format(timeFmt), id)
	return err
}

func (s *Store) UpsertItem(it *Item) error {
	now := time.Now().UTC()
	it.UpdatedAt = now
	if it.CreatedAt.IsZero() {
		it.CreatedAt = now
	}
	if it.State == "" {
		it.State = "packed"
	}
	_, err := s.db.Exec(`INSERT INTO items
		(id,name,description_cs,description_en,category,price_robux,tags,collection,limited,state,created_at,updated_at)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
		ON CONFLICT(id) DO UPDATE SET name=excluded.name, description_cs=excluded.description_cs,
		description_en=excluded.description_en, category=excluded.category,
		price_robux=excluded.price_robux, tags=excluded.tags, collection=excluded.collection,
		limited=excluded.limited, state=excluded.state, updated_at=excluded.updated_at`,
		it.ID, it.Name, it.DescriptionCS, it.DescriptionEN, it.Category, it.PriceRobux,
		string(it.Tags), it.Collection, string(it.Limited), it.State,
		it.CreatedAt.Format(timeFmt), it.UpdatedAt.Format(timeFmt))
	return err
}

func (s *Store) GetItem(id string) (*Item, error) {
	row := s.db.QueryRow(`SELECT id,name,description_cs,description_en,category,price_robux,tags,collection,limited,state,created_at,updated_at FROM items WHERE id=?`, id)
	return scanItem(row)
}

func scanItem(row interface{ Scan(...any) error }) (*Item, error) {
	var it Item
	var tags, limited, created, updated string
	if err := row.Scan(&it.ID, &it.Name, &it.DescriptionCS, &it.DescriptionEN, &it.Category,
		&it.PriceRobux, &tags, &it.Collection, &limited, &it.State, &created, &updated); err != nil {
		return nil, err
	}
	if tags != "" {
		it.Tags = json.RawMessage(tags)
	}
	if limited != "" {
		it.Limited = json.RawMessage(limited)
	}
	it.CreatedAt, _ = time.Parse(timeFmt, created)
	it.UpdatedAt, _ = time.Parse(timeFmt, updated)
	return &it, nil
}

func (s *Store) ListItems() ([]*Item, error) {
	rows, err := s.db.Query(`SELECT id,name,description_cs,description_en,category,price_robux,tags,collection,limited,state,created_at,updated_at FROM items ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := []*Item{}
	for rows.Next() {
		it, err := scanItem(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, it)
	}
	return items, rows.Err()
}

// SetJobBackend zaznamena, kterym backendem je aktualni mesh. Po remeshi
// jinak zustane v DB puvodni "sf3d", i kdyz model uz je z TRELLISu - a pak
// nejde poznat, jestli item nese draft nebo finalni mesh.
func (s *Store) SetJobBackend(id, backend string) error {
	_, err := s.db.Exec(`UPDATE jobs SET backend=?, updated_at=? WHERE id=?`,
		backend, time.Now().UTC().Format(timeFmt), id)
	return err
}

// ReleaseStuckRemeshing vrati do fronty joby, jejichz remesh nepreckal
// restart. Vola se pri startu.
func (s *Store) ReleaseStuckRemeshing() (int, error) {
	res, err := s.db.Exec(`UPDATE jobs SET status='approved', updated_at=? WHERE status='remeshing'`,
		time.Now().UTC().Format(timeFmt))
	if err != nil {
		return 0, err
	}
	n, _ := res.RowsAffected()
	return int(n), nil
}

func (s *Store) Ping() error {
	var one int
	if err := s.db.QueryRow("SELECT 1").Scan(&one); err != nil {
		return fmt.Errorf("db: %w", err)
	}
	return nil
}
