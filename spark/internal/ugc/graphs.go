package ugc

import (
	"fmt"
	"strings"
)

// Vyber modelu podle toho, co se generuje.
//
// Danbooru modely (Illustrious) znaji predmety - zbrane, helmy, kridla -
// a kresli je cistě a rychle. Neznaji ale nic, co v jejich trenovacich
// datech existuje jen na postave: obleceni, vlasy, sperk na krku. Tam
// nakresli bud postavu, nebo detail latky (overeno kolekci Dragon Couture).
//
// Fotorealisticke modely maji v datech produktove fotky z e-shopu, takze
// "saty na neviditelne figurine na bilem pozadi" jim jde prirozene
// (srovnavaci test 2026-08-22: Illustrious nakreslil draka, Juggernaut
// i FLUX spravne saty).
const (
	modelAnime = "Illustrious-XL-v2.0.safetensors"
	modelPhoto = "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
)

// wearOnBody jsou kategorie, ktere danbooru modely neumi samostatne.
var wearOnBody = map[string]bool{
	"hair": true, "neck": true, "front": true, "waist": true,
}

// PickModel vybere checkpoint a rezim promptu. Explicitni checkpoint
// z requestu ma prednost.
func PickModel(category, requested string) (checkpoint string, product bool) {
	if requested != "" {
		return requested, strings.Contains(strings.ToLower(requested), "juggernaut") ||
			strings.Contains(strings.ToLower(requested), "photo")
	}
	if wearOnBody[category] {
		return modelPhoto, true
	}
	return modelAnime, false
}

// productPrompt je ramec produktove fotky: cely predmet, zadna postava.
func productPrompt(prompt, style string) (string, string) {
	pos := fmt.Sprintf(
		"product photography of %s, %s, displayed on an invisible mannequin, "+
			"isolated on plain white background, studio lighting, "+
			"entire item visible, catalog photo",
		prompt, style)
	neg := "person, human, model, body, legs, arms, face, skin, hands, " +
		"close-up, cropped, partial, text, watermark, signature, logo, " +
		"blurry, child, nsfw, " + artNegatives
	return pos, neg
}

// Concept graph: checkpoint -> prompt -> KSampler -> PNG. Illustrious-style
// defaults; the prompt template frames the item as a single centred game
// asset so the mesh stage gets clean geometry.
func conceptGraph(checkpoint, prompt, negative string, seed int64, filenamePrefix string) map[string]any {
	return map[string]any{
		"1": node("CheckpointLoaderSimple", in{"ckpt_name": checkpoint}),
		"2": node("CLIPTextEncode", in{"clip": ref("1", 1), "text": prompt}),
		"3": node("CLIPTextEncode", in{"clip": ref("1", 1), "text": negative}),
		"4": node("EmptyLatentImage", in{"width": 1024, "height": 1024, "batch_size": 1}),
		// dpmpp_2m/karras je pro fotorealisticke modely vhodnejsi nez
		// euler_ancestral, ktery se hodi na anime styl
		"5": node("KSampler", in{
			"model": ref("1", 0), "positive": ref("2", 0), "negative": ref("3", 0),
			"latent_image": ref("4", 0), "seed": seed, "steps": 30, "cfg": 6.0,
			"sampler_name": "dpmpp_2m", "scheduler": "karras", "denoise": 1.0}),
		"6": node("VAEDecode", in{"samples": ref("5", 0), "vae": ref("1", 2)}),
		"7": node("SaveImage", in{"images": ref("6", 0), "filename_prefix": filenamePrefix}),
	}
}

// Cleanplate graph: RMBG-2.0 nad konceptem -> PNG s alfa kanalem.
func cleanplateGraph(inputImage, filenamePrefix string) map[string]any {
	return map[string]any{
		"1": node("LoadImage", in{"image": inputImage}),
		"2": node("RMBG", in{
			"image": ref("1", 0), "model": "RMBG-2.0", "sensitivity": 1.0,
			"process_res": 1024, "mask_blur": 0, "mask_offset": 0,
			"invert_output": false, "refine_foreground": true, "background": "Alpha"}),
		"3": node("SaveImage", in{"images": ref("2", 0), "filename_prefix": filenamePrefix}),
	}
}

// Mesh graph: the TRELLIS pipeline verified on 2026-08-21 (see
// AiStack/workflows/ugc/ugc_img2mesh_trellis.json). The bvh wire from the
// generator's second output is REQUIRED — without it ComfyUI silently skips
// the unwrap and export nodes and still reports success.
func trellisGraph(inputImage string, seed int64, filenamePrefix string) map[string]any {
	return map[string]any{
		"1": node("Trellis2LoadModel", in{
			"modelname": "microsoft/TRELLIS.2-4B", "backend": "sdpa", "device": "cuda",
			"low_vram": true, "keep_models_loaded": true, "conv_backend": "flex_gemm",
			"sparse_backend": "sdpa", "use_reconviagen": false}),
		// LoadImage zahazuje alfu; Trellis2LoadImageWithTransparency (slot 2)
		// ji drzi a preprocess s remove_background=false ji pouzije jako masku.
		// RMBG cleanplate ma mimo masku vynulovane RGB - bez alfy by TRELLIS
		// dostal cerny obrazek (presne tak spadl prvni tovarni beh).
		"2": node("Trellis2LoadImageWithTransparency", in{"image": inputImage}),
		"3": node("Trellis2PreProcessImage", in{
			"image": ref("2", 2), "padding": 0, "remove_background": false, "max_size": 2048}),
		"4": node("Trellis2MeshWithVoxelGenerator", in{
			"pipeline": ref("1", 0), "image": ref("3", 0), "seed": seed,
			"pipeline_type": "1024_cascade", "sparse_structure_steps": 12,
			"shape_steps": 12, "texture_steps": 12, "max_num_tokens": 49152,
			"max_views": 4, "sparse_structure_resolution": 32,
			"generate_texture_slat": true, "use_tiled_decoder": true,
			"sampler": "euler", "fill_holes": true, "hole_iterations": 1,
			"hole_fill_algorithm": "flood_fill", "keep_only_shell": true}),
		"5": node("Trellis2FillHolesWithCuMesh", in{"mesh": ref("4", 0), "max_permieters": 0.03}),
		"6": node("Trellis2ReconstructMeshWithQuad", in{
			"mesh": ref("5", 0), "remesh_band": 1.0, "resolution": 512,
			"remove_floaters": true, "remove_inner_faces": false}),
		"7": node("Trellis2SimplifyMesh", in{
			"mesh": ref("6", 0), "target_face_num": 30000, "method": "Meshlib"}),
		"8": node("Trellis2FillHolesWithMeshlib", in{"mesh": ref("7", 0)}),
		"9": node("Trellis2UnWrapAndRasterizer", in{
			"mesh": ref("8", 0), "bvh": ref("4", 1),
			"mesh_cluster_threshold_cone_half_angle_rad": 60.0,
			"mesh_cluster_refine_iterations":             0, "mesh_cluster_global_iterations": 1,
			"mesh_cluster_smooth_strength": 1, "texture_size": 2048,
			"texture_alpha_mode": "OPAQUE", "double_side_material": false,
			"bake_on_vertices": false, "use_custom_normals": false, "inpainting": "telea"}),
		"10": node("Trellis2ExportMesh", in{
			"trimesh": ref("9", 0), "filename_prefix": filenamePrefix, "file_format": "glb"}),
	}
}

type in map[string]any

func node(class string, inputs in) map[string]any {
	return map[string]any{"class_type": class, "inputs": map[string]any(inputs)}
}

func ref(id string, slot int) []any { return []any{id, slot} }

// artNegatives jsou vady, ktere Illustrious pridava sam od sebe, protoze je
// trenovany na "weapon sheet" ilustracich: ozdobne ramy, vic pohledu na jednu
// zbran a falesne podpisy/copyright. Vsechny se do meshe zamodeluji jako
// geometrie navic (overeno na kolekci Beast Arsenal 2026-08-22).
const artNegatives = "border, frame, ornate frame, weapon sheet, reference sheet, " +
	"multiple views, turnaround, collection, lineup, artist name, copyright, " +
	"english text, japanese text, label, caption"

// isSet pozna item slozeny z vic kusu (dvojice cepeli, mec + stit).
// U nich se nesmi vynucovat "single object" a negativ "multiple objects" -
// jinak model jeden z kusu zahodi.
func isSet(prompt string) bool {
	p := strings.ToLower(prompt)
	for _, kw := range []string{"pair", "dual", "twin", "and shield", "set of", "matching"} {
		if strings.Contains(p, kw) {
			return true
		}
	}
	return false
}

// PromptFor skladá finální prompt konceptu z kategorie a stylu.
func PromptFor(category, style, prompt string) (positive, negative string) {
	if isSet(prompt) {
		// Kusy musi byt vedle sebe a nepretinat se, aby z nich TRELLIS
		// udelal jeden souvisly mesh misto dvou kusu v jednom prostoru.
		pos := fmt.Sprintf(
			"masterpiece, best quality, no humans, still life, object focus, "+
				"%s, %s, arranged side by side, not overlapping, "+
				"centered, simple background, white background, game asset",
			prompt, style)
		neg := "1girl, 1boy, solo, character, full body, portrait, head, face, " +
			"hands, holding, wearing, mannequin, text, watermark, signature, " +
			"logo, cropped, blurry, child, loli, nsfw, " + artNegatives
		return pos, neg
	}

	// Illustrious/Pony jsou danbooru modely - anglicke vety ("no character",
	// "empty item") ignoruji a kresli postavy dal. Funguje doslovny tag
	// "no humans" + "still life"/"object focus"; negativ mluvi stejnym
	// dialektem (1girl/1boy/solo). Overeno: bez toho prisel bust i cely ninja.
	base := fmt.Sprintf(
		"masterpiece, best quality, no humans, still life, object focus, "+
			"%s, %s, single object, only one, isolated on plain background, "+
			"centered, simple background, white background, game asset",
		prompt, style)
	neg := "1girl, 1boy, solo, multiple girls, multiple boys, character, " +
		"full body, portrait, head, face, hands, mannequin, wearing, " +
		"text, watermark, signature, logo, multiple objects, two weapons, " +
		"duplicate, cropped, blurry, child, loli, nsfw, " + artNegatives
	_ = category
	return base, neg
}
