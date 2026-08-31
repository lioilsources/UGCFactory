package main

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

// Character is one fantasy figure travelling through the FC pipeline
// (docs/FANTASYCHARACTER_PLAN.md): a 2D image becomes a textured, rigged,
// animated 3D model.
//
//	uploaded → preprocessed → meshed → cleaned → rigged → animated → exported → done
//	  ↘ failed (kterykoliv krok; retry jde per krok, viz CharacterStep)
type Character struct {
	ID          string    `json:"id"`
	OwnerID     string    `json:"owner_id"`
	Name        string    `json:"name"`
	Status      string    `json:"status"`
	Error       string    `json:"error,omitempty"`
	SourceImage string    `json:"source_image"`
	APoseImage  string    `json:"apose_image,omitempty"`
	MeshGLB     string    `json:"mesh_glb,omitempty"`
	CleanGLB    string    `json:"clean_glb,omitempty"`
	RiggedFBX   string    `json:"rigged_fbx,omitempty"`
	FinalGLB    string    `json:"final_glb,omitempty"`
	FinalFBX    string    `json:"final_fbx,omitempty"`
	PreviewMP4  string    `json:"preview_mp4,omitempty"`
	ThumbPNG    string    `json:"thumb_png,omitempty"`
	TriCount    int64     `json:"tri_count,omitempty"`
	AutoAPose   bool      `json:"auto_apose"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Animation is one clip in the curated local library (/data/animlib). License
// matters: Mixamo clips may ship inside a project but not be redistributed on
// their own, so exports to paying users filter on it.
type Animation struct {
	ID         string          `json:"id"` // slug: idle_01, walk_forward
	Name       string          `json:"name"`
	Category   string          `json:"category"` // idle|locomotion|combat|emote|misc
	Source     string          `json:"source"`   // mixamo|cc0-quaternius|own
	License    string          `json:"license"`
	FBXPath    string          `json:"fbx_path"`
	PreviewGIF string          `json:"preview_gif,omitempty"`
	Frames     int64           `json:"frames"`
	FPS        int64           `json:"fps"`
	Loop       bool            `json:"loop"`
	Tags       json.RawMessage `json:"tags,omitempty"`
}

// CharacterAnimation is one clip baked into a character's merged timeline;
// retarget.py fills the frame range once the clips are laid end to end.
type CharacterAnimation struct {
	AnimationID string `json:"animation_id"`
	Name        string `json:"name,omitempty"`
	Category    string `json:"category,omitempty"`
	Loop        bool   `json:"loop"`
	FrameStart  int64  `json:"frame_start"`
	FrameEnd    int64  `json:"frame_end"`
}

// Export is one delivery of a finished character to a world or to the user.
type Export struct {
	ID           string    `json:"id"`
	CharacterID  string    `json:"character_id"`
	Target       string    `json:"target"` // roblox|luanti|user
	Status       string    `json:"status"` // pending|running|done|failed
	Error        string    `json:"error,omitempty"`
	ExternalID   string    `json:"external_id,omitempty"` // Roblox assetId
	ArtifactPath string    `json:"artifact_path,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// CharacterStep is one queued pipeline step. The plan asks for retry per step,
// so steps are rows rather than a single status column: a failed rig keeps its
// error while the next attempt gets its own row.
type CharacterStep struct {
	ID          int64     `json:"id"`
	CharacterID string    `json:"character_id"`
	Step        string    `json:"step"`
	Status      string    `json:"status"` // pending|running|done|failed
	Error       string    `json:"error,omitempty"`
	Attempt     int64     `json:"attempt"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// The pipeline as an ordered list. Each step, once done, moves the character
// to the status on the right and enqueues the next step.
const (
	StepPreprocess = "char.preprocess"
	StepMesh       = "char.mesh"
	StepClean      = "char.clean"
	StepRig        = "char.rig"
	StepAnimate    = "char.animate"
	StepExportUser = "char.export.user"
)

var pipeline = []struct{ Step, Status string }{
	{StepPreprocess, "preprocessed"},
	{StepMesh, "meshed"},
	{StepClean, "cleaned"},
	{StepRig, "rigged"},
	{StepAnimate, "animated"},
	{StepExportUser, "exported"},
}

// nextStep returns the step that follows the given one, "" at the end.
func nextStep(step string) string {
	for i, p := range pipeline {
		if p.Step == step && i+1 < len(pipeline) {
			return pipeline[i+1].Step
		}
	}
	return ""
}

// statusAfter is the character status once step finished successfully.
func statusAfter(step string) string {
	for _, p := range pipeline {
		if p.Step == step {
			return p.Status
		}
	}
	return ""
}

func knownStep(step string) bool {
	if strings.HasPrefix(step, "char.export.") {
		return validTarget(strings.TrimPrefix(step, "char.export."))
	}
	return statusAfter(step) != ""
}

func validTarget(t string) bool { return t == "roblox" || t == "luanti" || t == "user" }

// newID is the uuid stand-in: the plan says uuid, SQLite has no such type and
// the rest of the factory keys on opaque text ids anyway.
func newID() string {
	var b [16]byte
	if _, err := rand.Read(b[:]); err != nil {
		return fmt.Sprintf("fc-%d", time.Now().UnixNano())
	}
	return hex.EncodeToString(b[:])
}

// migrateCharacters adds the FC domain. Postgres DDL from the plan translated
// to SQLite: uuid → TEXT, timestamptz → TEXT RFC3339, text[] → JSON TEXT,
// bool → INTEGER. Same columns, same meaning.
func (s *Store) migrateCharacters() error {
	_, err := s.db.Exec(`
CREATE TABLE IF NOT EXISTS characters (
  id TEXT PRIMARY KEY, owner_id TEXT NOT NULL DEFAULT '', name TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL, error TEXT DEFAULT '', source_image TEXT NOT NULL DEFAULT '',
  apose_image TEXT DEFAULT '', mesh_glb TEXT DEFAULT '', clean_glb TEXT DEFAULT '',
  rigged_fbx TEXT DEFAULT '', final_glb TEXT DEFAULT '', final_fbx TEXT DEFAULT '',
  preview_mp4 TEXT DEFAULT '', thumb_png TEXT DEFAULT '', tri_count INTEGER DEFAULT 0,
  auto_apose INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS characters_status ON characters(status);
CREATE INDEX IF NOT EXISTS characters_owner ON characters(owner_id);

CREATE TABLE IF NOT EXISTS animations (
  id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '', category TEXT NOT NULL DEFAULT 'misc',
  source TEXT NOT NULL DEFAULT '', license TEXT NOT NULL DEFAULT '',
  fbx_path TEXT NOT NULL DEFAULT '', preview_gif TEXT DEFAULT '',
  frames INTEGER NOT NULL DEFAULT 0, fps INTEGER NOT NULL DEFAULT 30,
  loop INTEGER NOT NULL DEFAULT 0, tags TEXT DEFAULT ''
);
CREATE INDEX IF NOT EXISTS animations_category ON animations(category);

CREATE TABLE IF NOT EXISTS character_animations (
  character_id TEXT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  animation_id TEXT NOT NULL REFERENCES animations(id),
  frame_start INTEGER DEFAULT 0, frame_end INTEGER DEFAULT 0,
  PRIMARY KEY (character_id, animation_id)
);

CREATE TABLE IF NOT EXISTS exports (
  id TEXT PRIMARY KEY,
  character_id TEXT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  target TEXT NOT NULL, status TEXT NOT NULL, error TEXT DEFAULT '',
  external_id TEXT DEFAULT '', artifact_path TEXT DEFAULT '',
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS exports_character ON exports(character_id);

CREATE TABLE IF NOT EXISTS character_steps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id TEXT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  step TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'pending',
  error TEXT DEFAULT '', attempt INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS character_steps_queue ON character_steps(status, id);`)
	return err
}

const charCols = `id,owner_id,name,status,error,source_image,apose_image,mesh_glb,clean_glb,` +
	`rigged_fbx,final_glb,final_fbx,preview_mp4,thumb_png,tri_count,auto_apose,created_at,updated_at`

func scanCharacter(row interface{ Scan(...any) error }) (*Character, error) {
	var c Character
	var autoAPose int64
	var created, updated string
	if err := row.Scan(&c.ID, &c.OwnerID, &c.Name, &c.Status, &c.Error, &c.SourceImage,
		&c.APoseImage, &c.MeshGLB, &c.CleanGLB, &c.RiggedFBX, &c.FinalGLB, &c.FinalFBX,
		&c.PreviewMP4, &c.ThumbPNG, &c.TriCount, &autoAPose, &created, &updated); err != nil {
		return nil, err
	}
	c.AutoAPose = autoAPose != 0
	c.CreatedAt, _ = time.Parse(timeFmt, created)
	c.UpdatedAt, _ = time.Parse(timeFmt, updated)
	return &c, nil
}

func (s *Store) InsertCharacter(c *Character) error {
	now := time.Now().UTC()
	c.CreatedAt, c.UpdatedAt = now, now
	if c.ID == "" {
		c.ID = newID()
	}
	if c.Status == "" {
		c.Status = "uploaded"
	}
	autoAPose := int64(0)
	if c.AutoAPose {
		autoAPose = 1
	}
	_, err := s.db.Exec(`INSERT INTO characters (`+charCols+`)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
		c.ID, c.OwnerID, c.Name, c.Status, c.Error, c.SourceImage, c.APoseImage,
		c.MeshGLB, c.CleanGLB, c.RiggedFBX, c.FinalGLB, c.FinalFBX, c.PreviewMP4,
		c.ThumbPNG, c.TriCount, autoAPose,
		c.CreatedAt.Format(timeFmt), c.UpdatedAt.Format(timeFmt))
	return err
}

func (s *Store) GetCharacter(id string) (*Character, error) {
	return scanCharacter(s.db.QueryRow("SELECT "+charCols+" FROM characters WHERE id = ?", id))
}

func (s *Store) ListCharacters(owner, status string, limit int) ([]*Character, error) {
	q := "SELECT " + charCols + " FROM characters"
	var where []string
	var args []any
	if owner != "" {
		where = append(where, "owner_id = ?")
		args = append(args, owner)
	}
	if status != "" {
		where = append(where, "status = ?")
		args = append(args, status)
	}
	if len(where) > 0 {
		q += " WHERE " + strings.Join(where, " AND ")
	}
	q += " ORDER BY created_at DESC LIMIT ?"
	args = append(args, limit)
	rows, err := s.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []*Character{}
	for rows.Next() {
		c, err := scanCharacter(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (s *Store) DeleteCharacter(id string) error {
	_, err := s.db.Exec("DELETE FROM characters WHERE id = ?", id)
	return err
}

// SetCharacterStatus is the same compare-and-swap as SetJobStatus: move only
// when the character is still where the caller thinks it is.
func (s *Store) SetCharacterStatus(id, next string, from ...string) (bool, error) {
	q := "UPDATE characters SET status = ?, updated_at = ? WHERE id = ?"
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

func (s *Store) SetCharacterError(id, msg string) error {
	_, err := s.db.Exec("UPDATE characters SET status='failed', error=?, updated_at=? WHERE id=?",
		msg, time.Now().UTC().Format(timeFmt), id)
	return err
}

// artifactColumns is the whitelist a worker may write. Keeps a rogue result
// payload from touching status or ids.
var artifactColumns = map[string]bool{
	"apose_image": true, "mesh_glb": true, "clean_glb": true, "rigged_fbx": true,
	"final_glb": true, "final_fbx": true, "preview_mp4": true, "thumb_png": true,
	"tri_count": true,
}

func (s *Store) SetCharacterArtifacts(id string, fields map[string]any) error {
	if len(fields) == 0 {
		return nil
	}
	var sets []string
	var args []any
	for col, v := range fields {
		if !artifactColumns[col] {
			return fmt.Errorf("unknown artifact field %q", col)
		}
		sets = append(sets, col+" = ?")
		args = append(args, v)
	}
	args = append(args, time.Now().UTC().Format(timeFmt), id)
	_, err := s.db.Exec("UPDATE characters SET "+strings.Join(sets, ", ")+
		", updated_at = ? WHERE id = ?", args...)
	return err
}

// --- step queue ----------------------------------------------------------

const stepCols = "id,character_id,step,status,error,attempt,created_at,updated_at"

func scanStep(row interface{ Scan(...any) error }) (*CharacterStep, error) {
	var st CharacterStep
	var created, updated string
	if err := row.Scan(&st.ID, &st.CharacterID, &st.Step, &st.Status, &st.Error,
		&st.Attempt, &created, &updated); err != nil {
		return nil, err
	}
	st.CreatedAt, _ = time.Parse(timeFmt, created)
	st.UpdatedAt, _ = time.Parse(timeFmt, updated)
	return &st, nil
}

func (s *Store) EnqueueStep(characterID, step string) (*CharacterStep, error) {
	if !knownStep(step) {
		return nil, fmt.Errorf("unknown step %q", step)
	}
	var attempt int64
	s.db.QueryRow("SELECT COUNT(*) FROM character_steps WHERE character_id=? AND step=?",
		characterID, step).Scan(&attempt)
	now := time.Now().UTC().Format(timeFmt)
	res, err := s.db.Exec(`INSERT INTO character_steps
		(character_id,step,status,error,attempt,created_at,updated_at)
		VALUES (?,?,'pending','',?,?,?)`, characterID, step, attempt+1, now, now)
	if err != nil {
		return nil, err
	}
	id, _ := res.LastInsertId()
	return s.GetStep(id)
}

func (s *Store) GetStep(id int64) (*CharacterStep, error) {
	return scanStep(s.db.QueryRow("SELECT "+stepCols+" FROM character_steps WHERE id = ?", id))
}

// ClaimNextStep atomically hands one pending step to a worker, oldest first.
func (s *Store) ClaimNextStep() (*CharacterStep, error) {
	var id int64
	err := s.db.QueryRow(`UPDATE character_steps SET status='running', updated_at=?
		WHERE id = (SELECT id FROM character_steps WHERE status='pending' ORDER BY id LIMIT 1)
		RETURNING id`, time.Now().UTC().Format(timeFmt)).Scan(&id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return s.GetStep(id)
}

func (s *Store) FinishStep(id int64, status, errMsg string) (bool, error) {
	res, err := s.db.Exec(`UPDATE character_steps SET status=?, error=?, updated_at=?
		WHERE id=? AND status='running'`,
		status, errMsg, time.Now().UTC().Format(timeFmt), id)
	if err != nil {
		return false, err
	}
	n, _ := res.RowsAffected()
	return n > 0, nil
}

func (s *Store) ListSteps(characterID string) ([]*CharacterStep, error) {
	rows, err := s.db.Query("SELECT "+stepCols+" FROM character_steps WHERE character_id=? ORDER BY id", characterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []*CharacterStep{}
	for rows.Next() {
		st, err := scanStep(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, st)
	}
	return out, rows.Err()
}

// --- animation library ---------------------------------------------------

const animCols = "id,name,category,source,license,fbx_path,preview_gif,frames,fps,loop,tags"

func scanAnimation(row interface{ Scan(...any) error }) (*Animation, error) {
	var a Animation
	var loop int64
	var tags string
	if err := row.Scan(&a.ID, &a.Name, &a.Category, &a.Source, &a.License, &a.FBXPath,
		&a.PreviewGIF, &a.Frames, &a.FPS, &loop, &tags); err != nil {
		return nil, err
	}
	a.Loop = loop != 0
	if tags != "" {
		a.Tags = json.RawMessage(tags)
	}
	return &a, nil
}

func (s *Store) UpsertAnimation(a *Animation) error {
	loop := int64(0)
	if a.Loop {
		loop = 1
	}
	if a.FPS == 0 {
		a.FPS = 30
	}
	_, err := s.db.Exec(`INSERT INTO animations (`+animCols+`)
		VALUES (?,?,?,?,?,?,?,?,?,?,?)
		ON CONFLICT(id) DO UPDATE SET name=excluded.name, category=excluded.category,
		source=excluded.source, license=excluded.license, fbx_path=excluded.fbx_path,
		preview_gif=excluded.preview_gif, frames=excluded.frames, fps=excluded.fps,
		loop=excluded.loop, tags=excluded.tags`,
		a.ID, a.Name, a.Category, a.Source, a.License, a.FBXPath, a.PreviewGIF,
		a.Frames, a.FPS, loop, string(a.Tags))
	return err
}

func (s *Store) GetAnimation(id string) (*Animation, error) {
	return scanAnimation(s.db.QueryRow("SELECT "+animCols+" FROM animations WHERE id = ?", id))
}

// ListAnimations filters the library. tag matches inside the JSON array — the
// library is ~50 rows, so a LIKE beats carrying a join table.
func (s *Store) ListAnimations(category, tag, license string) ([]*Animation, error) {
	q := "SELECT " + animCols + " FROM animations"
	var where []string
	var args []any
	if category != "" {
		where = append(where, "category = ?")
		args = append(args, category)
	}
	if license != "" {
		where = append(where, "license = ?")
		args = append(args, license)
	}
	if tag != "" {
		where = append(where, "tags LIKE ?")
		args = append(args, "%\""+tag+"\"%")
	}
	if len(where) > 0 {
		q += " WHERE " + strings.Join(where, " AND ")
	}
	q += " ORDER BY category, id"
	rows, err := s.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []*Animation{}
	for rows.Next() {
		a, err := scanAnimation(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

// SetCharacterAnimations replaces the clip selection. Frame ranges are reset:
// they only mean something after retarget.py rebuilds the merged timeline.
func (s *Store) SetCharacterAnimations(characterID string, ids []string) error {
	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err := tx.Exec("DELETE FROM character_animations WHERE character_id = ?", characterID); err != nil {
		return err
	}
	for _, id := range ids {
		if _, err := tx.Exec(`INSERT INTO character_animations
			(character_id,animation_id,frame_start,frame_end) VALUES (?,?,0,0)`,
			characterID, id); err != nil {
			return fmt.Errorf("animation %q: %w", id, err)
		}
	}
	return tx.Commit()
}

// SetFrameRanges records the merged timeline retarget.py produced.
func (s *Store) SetFrameRanges(characterID string, ranges map[string][2]int64) error {
	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()
	for id, r := range ranges {
		if _, err := tx.Exec(`UPDATE character_animations SET frame_start=?, frame_end=?
			WHERE character_id=? AND animation_id=?`, r[0], r[1], characterID, id); err != nil {
			return err
		}
	}
	return tx.Commit()
}

func (s *Store) ListCharacterAnimations(characterID string) ([]*CharacterAnimation, error) {
	rows, err := s.db.Query(`SELECT ca.animation_id, COALESCE(a.name,''), COALESCE(a.category,''),
		COALESCE(a.loop,0), ca.frame_start, ca.frame_end
		FROM character_animations ca LEFT JOIN animations a ON a.id = ca.animation_id
		WHERE ca.character_id = ? ORDER BY ca.frame_start, ca.animation_id`, characterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []*CharacterAnimation{}
	for rows.Next() {
		var ca CharacterAnimation
		var loop int64
		if err := rows.Scan(&ca.AnimationID, &ca.Name, &ca.Category, &loop,
			&ca.FrameStart, &ca.FrameEnd); err != nil {
			return nil, err
		}
		ca.Loop = loop != 0
		out = append(out, &ca)
	}
	return out, rows.Err()
}

// --- exports -------------------------------------------------------------

const exportCols = "id,character_id,target,status,error,external_id,artifact_path,created_at,updated_at"

func scanExport(row interface{ Scan(...any) error }) (*Export, error) {
	var e Export
	var created, updated string
	if err := row.Scan(&e.ID, &e.CharacterID, &e.Target, &e.Status, &e.Error,
		&e.ExternalID, &e.ArtifactPath, &created, &updated); err != nil {
		return nil, err
	}
	e.CreatedAt, _ = time.Parse(timeFmt, created)
	e.UpdatedAt, _ = time.Parse(timeFmt, updated)
	return &e, nil
}

func (s *Store) InsertExport(e *Export) error {
	now := time.Now().UTC()
	e.CreatedAt, e.UpdatedAt = now, now
	if e.ID == "" {
		e.ID = newID()
	}
	if e.Status == "" {
		e.Status = "pending"
	}
	_, err := s.db.Exec(`INSERT INTO exports (`+exportCols+`) VALUES (?,?,?,?,?,?,?,?,?)`,
		e.ID, e.CharacterID, e.Target, e.Status, e.Error, e.ExternalID, e.ArtifactPath,
		e.CreatedAt.Format(timeFmt), e.UpdatedAt.Format(timeFmt))
	return err
}

func (s *Store) GetExport(id string) (*Export, error) {
	return scanExport(s.db.QueryRow("SELECT "+exportCols+" FROM exports WHERE id = ?", id))
}

func (s *Store) ListExports(characterID string) ([]*Export, error) {
	rows, err := s.db.Query("SELECT "+exportCols+" FROM exports WHERE character_id=? ORDER BY created_at DESC", characterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []*Export{}
	for rows.Next() {
		e, err := scanExport(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

func (s *Store) SetExportResult(id, status, errMsg, externalID, artifact string) error {
	_, err := s.db.Exec(`UPDATE exports SET status=?, error=?, external_id=?, artifact_path=?,
		updated_at=? WHERE id=?`, status, errMsg, externalID, artifact,
		time.Now().UTC().Format(timeFmt), id)
	return err
}

// PendingExport finds the export row a char.export.{target} step belongs to,
// so the worker's result lands on the right delivery.
func (s *Store) PendingExport(characterID, target string) (*Export, error) {
	return scanExport(s.db.QueryRow("SELECT "+exportCols+
		` FROM exports WHERE character_id=? AND target=? AND status IN ('pending','running')
		  ORDER BY created_at DESC LIMIT 1`, characterID, target))
}
