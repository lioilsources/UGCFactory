package main

import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"image"
	"image/png"
	"os"
)

// Preview GLB: tentyz model, ale s texturami zmensenymi na previewTexture px.
//
// TRELLIS exportuje 2048x2048 PNG a cely GLB ma pak ~12 MB. Takovy model
// se v <model-viewer> nevykresli - overeno headless Chromem: geometrie
// sama i tytez textury zmensene se zobrazi, plna verze skonci cernou
// plochou bez chyby. Pro nahled je to stejne zbytecna data (a na mobilu
// drahy prenos), takze si vedle plne verze drzime lehkou.
const previewTexture = 512

// makePreviewGLB reads a GLB, downsamples every embedded PNG and writes the
// result. Konverze na FBX porad pracuje s plnou verzi.
func makePreviewGLB(srcPath, dstPath string) error {
	raw, err := os.ReadFile(srcPath)
	if err != nil {
		return err
	}
	doc, bin, err := splitGLB(raw)
	if err != nil {
		return err
	}

	var g struct {
		Images []struct {
			BufferView int `json:"bufferView"`
		} `json:"images"`
		BufferViews []map[string]any `json:"bufferViews"`
		Buffers     []map[string]any `json:"buffers"`
	}
	if err := json.Unmarshal(doc, &g); err != nil {
		return err
	}
	isImage := map[int]bool{}
	for _, im := range g.Images {
		isImage[im.BufferView] = true
	}

	var raw2 map[string]any
	if err := json.Unmarshal(doc, &raw2); err != nil {
		return err
	}
	views, _ := raw2["bufferViews"].([]any)

	var newBin bytes.Buffer
	for i, v := range views {
		bv, _ := v.(map[string]any)
		off := intOf(bv["byteOffset"])
		length := intOf(bv["byteLength"])
		if off+length > len(bin) {
			return fmt.Errorf("bufferView %d mimo rozsah", i)
		}
		chunk := bin[off : off+length]
		if isImage[i] {
			if small, err := shrinkPNG(chunk, previewTexture); err == nil {
				chunk = small
			}
		}
		bv["byteOffset"] = newBin.Len()
		bv["byteLength"] = len(chunk)
		delete(bv, "byteStride")
		newBin.Write(chunk)
		for newBin.Len()%4 != 0 {
			newBin.WriteByte(0)
		}
	}
	raw2["buffers"] = []any{map[string]any{"byteLength": newBin.Len()}}

	newDoc, err := json.Marshal(raw2)
	if err != nil {
		return err
	}
	for len(newDoc)%4 != 0 {
		newDoc = append(newDoc, ' ')
	}
	out := buildGLB(newDoc, newBin.Bytes())
	return os.WriteFile(dstPath, out, 0o644)
}

func intOf(v any) int {
	if f, ok := v.(float64); ok {
		return int(f)
	}
	return 0
}

func splitGLB(raw []byte) (doc, bin []byte, err error) {
	if len(raw) < 20 || string(raw[0:4]) != "glTF" {
		return nil, nil, fmt.Errorf("neni GLB")
	}
	off := 12
	for off+8 <= len(raw) {
		clen := int(binary.LittleEndian.Uint32(raw[off:]))
		ctype := binary.LittleEndian.Uint32(raw[off+4:])
		start := off + 8
		if start+clen > len(raw) {
			return nil, nil, fmt.Errorf("poskozeny chunk")
		}
		switch ctype {
		case 0x4E4F534A: // JSON
			doc = raw[start : start+clen]
		case 0x004E4942: // BIN
			bin = raw[start : start+clen]
		}
		off = start + clen
	}
	if doc == nil {
		return nil, nil, fmt.Errorf("chybi JSON chunk")
	}
	return doc, bin, nil
}

func buildGLB(doc, bin []byte) []byte {
	total := 12 + 8 + len(doc) + 8 + len(bin)
	out := make([]byte, 0, total)
	hdr := make([]byte, 12)
	copy(hdr, "glTF")
	binary.LittleEndian.PutUint32(hdr[4:], 2)
	binary.LittleEndian.PutUint32(hdr[8:], uint32(total))
	out = append(out, hdr...)
	ch := make([]byte, 8)
	binary.LittleEndian.PutUint32(ch, uint32(len(doc)))
	binary.LittleEndian.PutUint32(ch[4:], 0x4E4F534A)
	out = append(out, ch...)
	out = append(out, doc...)
	binary.LittleEndian.PutUint32(ch, uint32(len(bin)))
	binary.LittleEndian.PutUint32(ch[4:], 0x004E4942)
	out = append(out, ch...)
	return append(out, bin...)
}

// shrinkPNG box-filtruje obrazek tak, aby delsi hrana byla max size.
func shrinkPNG(data []byte, size int) ([]byte, error) {
	src, err := png.Decode(bytes.NewReader(data))
	if err != nil {
		return nil, err
	}
	b := src.Bounds()
	if b.Dx() <= size && b.Dy() <= size {
		return data, nil
	}
	scale := b.Dx()
	if b.Dy() > scale {
		scale = b.Dy()
	}
	w := b.Dx() * size / scale
	h := b.Dy() * size / scale
	dst := image.NewNRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		y0, y1 := y*b.Dy()/h, (y+1)*b.Dy()/h
		if y1 <= y0 {
			y1 = y0 + 1
		}
		for x := 0; x < w; x++ {
			x0, x1 := x*b.Dx()/w, (x+1)*b.Dx()/w
			if x1 <= x0 {
				x1 = x0 + 1
			}
			var r, g, bl, a, n uint32
			for sy := y0; sy < y1; sy++ {
				for sx := x0; sx < x1; sx++ {
					cr, cg, cb, ca := src.At(b.Min.X+sx, b.Min.Y+sy).RGBA()
					r += cr >> 8
					g += cg >> 8
					bl += cb >> 8
					a += ca >> 8
					n++
				}
			}
			i := dst.PixOffset(x, y)
			dst.Pix[i] = uint8(r / n)
			dst.Pix[i+1] = uint8(g / n)
			dst.Pix[i+2] = uint8(bl / n)
			dst.Pix[i+3] = uint8(a / n)
		}
	}
	var buf bytes.Buffer
	enc := png.Encoder{CompressionLevel: png.BestCompression}
	if err := enc.Encode(&buf, dst); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}
