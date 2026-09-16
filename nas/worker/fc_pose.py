"""Detekce pozy a oprava srostlych koncetin pred TRELLISem (plan sekce 14).

Srostle ruce u tela a stehna u sebe delaji TRELLISu jeden objem geometrie -
rig pak muze jen prerozdelit vahy na tom, co uz je srostle, takze paze pri
animaci taha za sebou blanu az k boku (zmereno na peti postavach, docs/
FANTASYCHARACTER_PLAN.md sekce 13 a 14). Jedina oprava je zasahnout pred
TRELLISem: odtahnout koncetiny od tela na fotce, aby TRELLIS srust vubec
nevyrobil.

Tenhle modul rozhoduje (podle DWPose kloubu) a stavi ComfyUI grafy pro dva
volitelne kroky pred RMBG (`char.preprocess`):

  - outpaint chybejicich nohou (FLUX Fill), kdyz DWPose nevidi kotniky
  - A-pose (Wan Animate, zaloha FLUX Kontext), kdyz poza jeste neni A-poza
    (APOSE_MIN_ARM_ANGLE, APOSE_MIN_WRIST_GAP)

Vse tady je ciste - zadne site ani IO, testovatelne bez ComfyUI stejne jako
fc_ranges.py. Orchestraci (upload, submit, stazeni) dela fc_worker.py.
"""
import math
import struct

# Body OpenPose-18: 0 nos, 1 krk (stred ramen), 2/5 prave/leve rameno,
# 3/6 loket, 4/7 zapesti, 8/11 bok, 9/12 koleno, 10/13 kotnik, 14-17 oci/usi.
NECK, RSHO, LSHO, RELB, LELB, RWRI, LWRI = 1, 2, 5, 3, 6, 4, 7
RHIP, LHIP, RKNEE, LKNEE, RANK, LANK = 8, 11, 9, 12, 10, 13
CONF_MIN = 0.3

# Kdy uz je poza A-poza - stejny prah rozhoduje pred prepozovanim (jestli
# ho vubec pustit) i po nem (jestli se vysledek prijme).
#
# Zmereno 2026-09-16 na 12 postavach (DWPose na vystupu Kontextu): ctyri,
# ktere dopadly dobre (mesh s oddelenymi pazemi), mely uhel paze 18-26 stupnu
# a mezeru zapesti 1.02-1.18; osm spatnych (paze dal podel tela nebo beze
# zmeny) 7-14 stupnu a mezeru do 0.95 - nebo velky uhel s malou mezerou
# (ruka na boku, za hlavou). Proto obe podminky zaroven.
#
# Mezera zapesti sama nestaci ani jako vstupni brana: meri se od OSY trupu,
# takze u sirokych boku vyjde velka, i kdyz paze lezi na tele. Dve malby z
# Ol1nLLM 2026-09-16 (rukama podel tela) mely uhel 1.7 a 2.0 stupne, ale
# mezeru 1.32 a 1.33 - drivejsi brana (mezera < 0.85) je pustila bez opravy
# a TRELLIS je odlil s pazemi srostlymi s trupem.
APOSE_MIN_ARM_ANGLE = 18.0
APOSE_MIN_WRIST_GAP = 1.0

# Kolik nasobku trupu sahaji nohy pod boky - z Mixamo kostry (stehno+holen)
# / trup = 1.92, plus chodidlo a rezerva. Urcuje, o kolik pixelu dole se
# vyplati outpaintovat, kdyz kotniky nejsou videt.
LEGS_BELOW_HIPS = 2.2

# Kotnik se bere jako skutecny, jen kdyz je aspon tolik trupu pod boky.
# Zmereno 2026-09-16 na 16 postavach: opravdove nohy 1.36-2.27 (nejmene
# selfie z nizka), fotka useknuta v pulce stehen, kde DWPose kotniky
# "nasel" s confidence 1.0: 0.92 - ta bez outpaintu skoncila bez nohou.
LEG_MIN_RATIO = 1.2

# Jednobarevne pruhy na okrajich (cerny pas prehravace / stavova lista na
# screenshotu z telefonu) se pred vsim odriznou (blender_scripts/
# fc_trim_bars.py): FLUX Fill jinak "domysli nohy" pod cerny pruh a namaluje
# tam nesmysl. Zmereno 2026-09-16: radky pruhu maji std 0, radky fotky
# aspon 14 (studio i tmave pozadi); pruh je 2.6-10 % vysky.
BAR_STD_MAX = 8.0
BAR_MIN_FRAC = 0.01

# Podrobny prompt drzi identitu (tvar ArcFace 0.96 na fotce); kratky
# ("same person... A-pose") ji srazi na 0.72-0.73 - nikdy nepouzivat kratky.
KONTEXT_APOSE_PROMPT = (
    "Keep this exact person unchanged: same face, hair, body, clothes and "
    "background. Change only the pose: the person stands upright facing the "
    "camera in a relaxed A-pose, both arms straight and held out slightly "
    "away from the body at about 35 degrees, palms open, feet planted "
    "shoulder-width apart. Whole body from head to feet visible."
)
OUTPAINT_LEGS_PROMPT = (
    "Continue the same figure downward, seamlessly: the legs of the same "
    "person in the same clothing and the same art style, standing straight "
    "and facing the camera, feet shoulder-width apart, matching shoes, on a "
    "plain flat floor, consistent lighting. Full body visible from head to feet."
)
# Pevny seed z experimentu 2026-09-15 (fc_pose_exp.py) - cislo samo nema
# vyznam, ale pevny znamena, ze retry dava stejny vysledek.
POSE_FIX_SEED = 11

# Wan Animate prepozovani (repose_graph): 480x832 je nativni 480p rozliseni
# modelu na vysku; TRELLIS si vstup stejne zmensuje na 518 px, takze o
# detail se neprichazi. 5 snimku = nejkratsi delka 4k+1, vsechny stejna poza.
REPOSE_W, REPOSE_H = 480, 832
REPOSE_FRAMES = 5
REPOSE_PROMPT = (
    "the same person standing still in an A-pose, arms held straight out away "
    "from the body, facing the camera, full body, sharp, high quality"
)


def parse_pose_keypoints(saved_json, width, height):
    """Klouby prvniho cloveka z vystupu SavePoseKpsAsJsonFile, prepocitane
    do pixelu skutecneho obrazku (DWPose canvas muze mit jine rozliseni
    nez original - resolution parametr ho skaluje).

    Vraci [(x, y, confidence), ...] 18 bodu, nebo None kdyz DWPose nikoho
    nenasel (prazdny seznam "people")."""
    frame = saved_json[0] if isinstance(saved_json, list) else saved_json
    people = frame.get("people") or []
    if not people:
        return None
    raw = people[0]["pose_keypoints_2d"]
    cw = frame.get("canvas_width") or width
    ch = frame.get("canvas_height") or height
    return [(raw[i] * width / cw, raw[i + 1] * height / ch, raw[i + 2])
            for i in range(0, min(len(raw), 54), 3)]


def _dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def pose_metrics(kps):
    """Z 18 kloubu spocita, co rozhoduje o outpaintu a A-poze: uhel a
    vodorovna mezera zapesti od osy trupu (prumer pres obe paze, min z
    obou pro gate - staci, aby jedna byla srostla), a jestli jsou videt
    kotniky. Vraci {"error": ...}, kdyz chybi ramena nebo boky - bez nich
    nejde spocitat nic z toho a oba kroky se preskoci."""
    def ok(i):
        return kps[i][2] > CONF_MIN

    if not (ok(RSHO) and ok(LSHO) and ok(RHIP) and ok(LHIP)):
        return {"error": "chybi ramena nebo boky"}
    neck, rsho, lsho, rhip, lhip = kps[NECK], kps[RSHO], kps[LSHO], kps[RHIP], kps[LHIP]
    hip = ((rhip[0] + lhip[0]) / 2, (rhip[1] + lhip[1]) / 2)
    shoulder_w = _dist(rsho, lsho)
    if shoulder_w < 1.0:
        return {"error": "ramena na jednom bode"}
    torso = _dist(neck, hip)
    m = {"shoulder_w": round(shoulder_w, 1), "torso": round(torso, 1), "hip_y": round(hip[1], 1)}

    def arm(sho, elb, wri):
        if not (ok(elb) and ok(wri)):
            return None
        s, _, w_ = kps[sho], kps[elb], kps[wri]
        ang = math.degrees(math.atan2(abs(w_[0] - s[0]), max(w_[1] - s[1], 1e-6)))
        # vodorovna vzdalenost zapesti od osy trupu ve vysce zapesti (osa
        # jde od krku k bokum, ne svisle - postava muze byt v talii vytocena)
        t = (w_[1] - neck[1]) / max(hip[1] - neck[1], 1e-6)
        axis_x = neck[0] + (hip[0] - neck[0]) * t
        return {"angle_deg": round(ang, 1), "wrist_gap": round(abs(w_[0] - axis_x) / shoulder_w, 2)}

    arms = [a for a in (arm(RSHO, RELB, RWRI), arm(LSHO, LELB, LWRI)) if a]
    if arms:
        m["arm_angle_deg"] = round(sum(a["angle_deg"] for a in arms) / len(arms), 1)
        m["wrist_gap_min"] = round(min(a["wrist_gap"] for a in arms), 2)
    m["ankles_visible"] = ok(RANK) and ok(LANK)
    if m["ankles_visible"]:
        # DWPose kotniky "vidi" i na fotce useknute v pulce stehen (confidence
        # 1.0 u bodu tesne nad spodnim okrajem) - skutecne kotniky jsou ale
        # aspon LEG_MIN_RATIO trupu pod boky, hadane ne
        ankle_y = max(kps[RANK][1], kps[LANK][1])
        m["leg_ratio"] = round((ankle_y - hip[1]) / max(torso, 1e-6), 2)
        m["ankles_visible"] = m["leg_ratio"] >= LEG_MIN_RATIO
    if m["ankles_visible"]:
        m["ankle_spread"] = round(_dist(kps[RANK], kps[LANK]) / shoulder_w, 2)
    return m


def needs_leg_outpaint(metrics):
    return "error" not in metrics and not metrics.get("ankles_visible")


def needs_arm_reshape(metrics):
    """Prepozovat se nemusi jen uz hotova A-poza. Bez merenych pazi se
    neprepozovava - vysledek by nesel zkontrolovat (apose_accepted)."""
    if "error" in metrics or "wrist_gap_min" not in metrics or "arm_angle_deg" not in metrics:
        return False
    return not apose_accepted(metrics)


def apose_accepted(metrics):
    """Vystup prepozovani se bere jen kdyz jsou paze opravdu od tela - jinak
    by TRELLIS dostal stejne srostlou postavu jako predtim (jen jinak
    nakreslenou) a cely krok by byl k nicemu."""
    if "error" in metrics or "arm_angle_deg" not in metrics:
        return False
    return (metrics["arm_angle_deg"] >= APOSE_MIN_ARM_ANGLE
            and metrics["wrist_gap_min"] >= APOSE_MIN_WRIST_GAP)


def apose_score(metrics):
    """Poradi kandidatu, kdyz zadny neprosel apose_accepted: vetsi mezera
    zapesti = mene srustu (to je to, na cem TRELLIS ztroskota)."""
    if "error" in metrics or "wrist_gap_min" not in metrics:
        return -1.0
    return metrics["wrist_gap_min"]


def outpaint_bottom_px(metrics, image_height):
    """Kolik pixelu dole domyslet, zaokrouhleno na 16 (FLUX Fill/
    ImagePadForOutpaint pozaduje nasobky 16). 0 = odhadovana podlaha uz je
    v obrazku (kotniky jen neduverihodne detekovane, ne chybejici) - neni
    co delat."""
    floor_y = metrics["hip_y"] + LEGS_BELOW_HIPS * metrics["torso"]
    extra = max(floor_y - image_height, 0)
    return int(math.ceil(extra / 16) * 16)


def bar_bounds(row_std, height, std_max=BAR_STD_MAX, min_frac=BAR_MIN_FRAC):
    """Kolik radku odriznout nahore a dole: souvisly pas "plochych" radku
    (smerodatna odchylka pixelu v radku pod std_max, v 0-255) od kraje.
    Pas kratsi nez min_frac vysky se nechava (kompresni artefakt, ne pruh);
    kdyz je plochy cely obrazek, nerezeme nic."""
    n = len(row_std)
    top = 0
    while top < n and row_std[top] < std_max:
        top += 1
    if top >= n:
        return 0, 0
    bottom = 0
    while bottom < n and row_std[n - 1 - bottom] < std_max:
        bottom += 1
    limit = min_frac * height
    return (top if top >= limit else 0), (bottom if bottom >= limit else 0)


def image_size(path):
    """Sirka a vyska PNG/JPEG bez zavislosti navic (worker kontejner nema
    Pillow ani cv2 - jen system python3, viz Dockerfile)."""
    with open(path, "rb") as f:
        sig = f.read(8)
        if sig == b"\x89PNG\r\n\x1a\n":
            rest = f.read(24)
            if len(rest) < 16:
                raise RuntimeError(f"{path}: usekle PNG")
            w, h = struct.unpack(">II", rest[8:16])
            return w, h
        if sig[:2] == b"\xff\xd8":
            f.seek(2)
            while True:
                marker = f.read(2)
                if len(marker) < 2 or marker[0] != 0xFF:
                    raise RuntimeError(f"{path}: poskozeny JPEG (chybi marker)")
                kind = marker[1]
                if kind in (0xC0, 0xC1, 0xC2, 0xC3):
                    f.read(3)  # delka segmentu (2) + presnost (1) - neresi se
                    h, w = struct.unpack(">HH", f.read(4))
                    return w, h
                if kind == 0xD9 or 0xD0 <= kind <= 0xD7:
                    continue  # markery bez delky
                (seg_len,) = struct.unpack(">H", f.read(2))
                f.seek(seg_len - 2, 1)
        raise RuntimeError(f"{path}: neni PNG ani JPEG")


# ------------------------------------------------------------------ grafy
#
# Obrazek je uz nahrany na ComfyUI (viz fc_worker.comfy_upload) - grafy
# dostavaji rovnou jeho jmeno, ne titulek k dohledani jako u statickych
# workflow souboru v nas/workflows/ (tam worker nezna cisla nodu; tady je
# sam stavi, takze zna).

def pose_graph(image, prefix, bbox_detector="yolox_l.onnx"):
    """DWPose na obrazku; POSE_KEYPOINT ulozi jako JSON, zadny nahled -
    kreslic uz mel svuj ucel splnit pri interaktivnim ladeni (fc_pose_exp.py,
    scratch)."""
    return {
        "1": {"class_type": "LoadImage", "inputs": {"image": image, "upload": "image"}},
        "2": {"class_type": "DWPreprocessor",
              "inputs": {"image": ["1", 0], "detect_hand": "disable", "detect_body": "enable",
                        "detect_face": "disable", "resolution": 1024, "bbox_detector": bbox_detector,
                        "pose_estimator": "dw-ll_ucoco_384.onnx", "scale_stick_for_xinsr_cn": "disable"}},
        "3": {"class_type": "SavePoseKpsAsJsonFile", "inputs": {"pose_kps": ["2", 1], "filename_prefix": prefix}},
    }


def outpaint_graph(image, bottom_px, prompt, seed, prefix):
    """FLUX Fill: domysli `bottom_px` pixelu dole, viditelna cast beze
    zmeny (InpaintModelConditioning s noise_mask - stejny graf jako
    Ol1nLLM assets/comfyui/flux_fill_inpaint.api.json, bez crop&stitch,
    protoze se maluje az za okrajem puvodniho obrazku, ne uvnitr)."""
    return {
        "30": {"class_type": "LoadImage", "inputs": {"image": image, "upload": "image"}},
        "31": {"class_type": "ImagePadForOutpaint",
              "inputs": {"image": ["30", 0], "left": 0, "top": 0, "right": 0,
                        "bottom": bottom_px, "feathering": 40}},
        "10": {"class_type": "UNETLoader",
              "inputs": {"unet_name": "flux1-fill-dev-fp8.safetensors", "weight_dtype": "fp8_e4m3fn"}},
        "11": {"class_type": "DualCLIPLoader",
              "inputs": {"clip_name1": "t5xxl_fp16.safetensors", "clip_name2": "clip_l.safetensors", "type": "flux"}},
        "12": {"class_type": "VAELoader", "inputs": {"vae_name": "ae.safetensors"}},
        "14": {"class_type": "CLIPTextEncode", "inputs": {"text": prompt, "clip": ["11", 0]}},
        "15": {"class_type": "CLIPTextEncode", "inputs": {"text": "", "clip": ["11", 0]}},
        "16": {"class_type": "FluxGuidance", "inputs": {"guidance": 30.0, "conditioning": ["14", 0]}},
        "42": {"class_type": "InpaintModelConditioning",
              "inputs": {"positive": ["16", 0], "negative": ["15", 0], "vae": ["12", 0],
                        "pixels": ["31", 0], "mask": ["31", 1], "noise_mask": True}},
        "18": {"class_type": "KSampler",
              "inputs": {"seed": seed, "steps": 28, "cfg": 1.0, "sampler_name": "euler", "scheduler": "simple",
                        "denoise": 1.0, "model": ["10", 0], "positive": ["42", 0], "negative": ["42", 1],
                        "latent_image": ["42", 2]}},
        "19": {"class_type": "VAEDecode", "inputs": {"samples": ["18", 0], "vae": ["12", 0]}},
        "20": {"class_type": "SaveImage", "inputs": {"filename_prefix": prefix, "images": ["19", 0]}},
    }


def kontext_graph(image, prompt, seed, prefix):
    """FLUX Kontext: prepozuje beze zmeny identity (stejny graf jako Ol1nLLM
    assets/comfyui/flux_hair_kontext.api.json, bez masky - meni se cela
    poza, ne jen vlasy), meritko zpet na puvodni rozliseni."""
    return {
        "1": {"class_type": "UNETLoader",
              "inputs": {"unet_name": "flux1-dev-kontext_fp8_scaled.safetensors", "weight_dtype": "fp8_e4m3fn"}},
        "2": {"class_type": "DualCLIPLoader",
              "inputs": {"clip_name1": "t5xxl_fp16.safetensors", "clip_name2": "clip_l.safetensors", "type": "flux"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "ae.safetensors"}},
        "4": {"class_type": "LoadImage", "inputs": {"image": image, "upload": "image"}},
        "5": {"class_type": "GetImageSize", "inputs": {"image": ["4", 0]}},
        "6": {"class_type": "FluxKontextImageScale", "inputs": {"image": ["4", 0]}},
        "7": {"class_type": "VAEEncode", "inputs": {"pixels": ["6", 0], "vae": ["3", 0]}},
        "8": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["2", 0], "text": prompt}},
        "9": {"class_type": "ReferenceLatent", "inputs": {"conditioning": ["8", 0], "latent": ["7", 0]}},
        "10": {"class_type": "FluxGuidance", "inputs": {"conditioning": ["9", 0], "guidance": 2.5}},
        "11": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["2", 0], "text": ""}},
        "12": {"class_type": "KSampler",
              "inputs": {"model": ["1", 0], "positive": ["10", 0], "negative": ["11", 0],
                        "latent_image": ["7", 0], "seed": seed, "steps": 28, "cfg": 1.0,
                        "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0}},
        "13": {"class_type": "VAEDecode", "inputs": {"samples": ["12", 0], "vae": ["3", 0]}},
        "14": {"class_type": "ImageScale",
              "inputs": {"image": ["13", 0], "upscale_method": "lanczos",
                        "width": ["5", 0], "height": ["5", 1], "crop": "disabled"}},
        "20": {"class_type": "SaveImage", "inputs": {"images": ["14", 0], "filename_prefix": prefix}},
    }


def repose_graph(reference, driver, seed, prefix, frames=REPOSE_FRAMES, retarget=True):
    """Wan 2.2 Animate jako prepozovani: postava z `reference` se
    prerenderuje do pozy, kterou ma clovek na `driver` (ridici A-pose fotka,
    assets/apose_driver.png). Model je na to stavany - drzi tvar, oblecani i
    pozadi (ArcFace 0.74-0.77 k originalu), a pozu prevezme presne (paze 45
    stupnu, zatimco Kontext je tahal na 10-14 a pipeline to nepoznala).
    Zapojeni podle ComfyUI-WanAnimatePreprocess/example_workflows/
    WanAnimate_native_example_01.json v rezimu animace (bez pozadi a masky);
    lightx2v distil LoRA = 4 kroky, cfg 1. Jedna poza = `frames` stejnych
    snimku (video model chce 4k+1), bere se posledni.

    `retarget` napasuje kostru z driveru na proporce reference (oficialni
    retarget_pose); bez nej ma vystup proporce driveru."""
    resize = {"width": REPOSE_W, "height": REPOSE_H, "upscale_method": "lanczos", "keep_proportion": "pad",
              "pad_color": "128, 128, 128", "crop_position": "center", "divisible_by": 16, "device": "cpu"}
    detect = {"model": ["10", 0], "images": ["9", 0], "width": REPOSE_W, "height": REPOSE_H, "face_padding": 0}
    if retarget:
        detect["retarget_image"] = ["8", 0]
    return {
        "1": {"class_type": "UNETLoader",
              "inputs": {"unet_name": "wan2.2_animate_14B_fp8_scaled_e4m3fn.safetensors", "weight_dtype": "default"}},
        "2": {"class_type": "LoraLoaderModelOnly",
              "inputs": {"model": ["1", 0], "strength_model": 1.2,
                         "lora_name": "lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors"}},
        "3": {"class_type": "CLIPLoader",
              "inputs": {"clip_name": "umt5_xxl_fp8_e4m3fn_scaled.safetensors", "type": "wan", "device": "default"}},
        "4": {"class_type": "VAELoader", "inputs": {"vae_name": "wan_2.1_vae.safetensors"}},
        "5": {"class_type": "CLIPVisionLoader", "inputs": {"clip_name": "CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"}},
        "6": {"class_type": "LoadImage", "inputs": {"image": reference, "upload": "image"}},
        "7": {"class_type": "LoadImage", "inputs": {"image": driver, "upload": "image"}},
        "8": {"class_type": "ImageResizeKJv2", "inputs": {"image": ["6", 0], **resize}},
        "9": {"class_type": "ImageResizeKJv2", "inputs": {"image": ["7", 0], **resize}},
        "10": {"class_type": "OnnxDetectionModelLoader",
               "inputs": {"vitpose_model": "vitpose-l-wholebody.onnx", "yolo_model": "yolov10m.onnx",
                          "onnx_device": "CUDAExecutionProvider"}},
        "11": {"class_type": "PoseAndFaceDetection", "inputs": detect},
        "12": {"class_type": "DrawViTPose",
               "inputs": {"pose_data": ["11", 0], "width": REPOSE_W, "height": REPOSE_H, "retarget_padding": 16,
                          "body_stick_width": -1, "hand_stick_width": -1, "draw_head": True}},
        "13": {"class_type": "RepeatImageBatch", "inputs": {"image": ["12", 0], "amount": frames}},
        "14": {"class_type": "CLIPVisionEncode", "inputs": {"clip_vision": ["5", 0], "image": ["8", 0], "crop": "none"}},
        "15": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["3", 0], "text": REPOSE_PROMPT}},
        "16": {"class_type": "ConditioningZeroOut", "inputs": {"conditioning": ["15", 0]}},
        "17": {"class_type": "WanAnimateToVideo",
               "inputs": {"positive": ["15", 0], "negative": ["16", 0], "vae": ["4", 0],
                          "width": REPOSE_W, "height": REPOSE_H, "length": frames, "batch_size": 1,
                          "continue_motion_max_frames": 5, "video_frame_offset": 0,
                          "clip_vision_output": ["14", 0], "reference_image": ["8", 0], "pose_video": ["13", 0]}},
        "18": {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}},
        "19": {"class_type": "CFGGuider",
               "inputs": {"model": ["2", 0], "positive": ["17", 0], "negative": ["17", 1], "cfg": 1.0}},
        "20": {"class_type": "KSamplerSelect", "inputs": {"sampler_name": "lcm"}},
        "21": {"class_type": "BasicScheduler",
               "inputs": {"model": ["2", 0], "scheduler": "simple", "steps": 4, "denoise": 1.0}},
        "22": {"class_type": "SamplerCustomAdvanced",
               "inputs": {"noise": ["18", 0], "guider": ["19", 0], "sampler": ["20", 0], "sigmas": ["21", 0],
                          "latent_image": ["17", 2]}},
        "23": {"class_type": "TrimVideoLatent", "inputs": {"samples": ["22", 0], "trim_amount": ["17", 3]}},
        "24": {"class_type": "VAEDecode", "inputs": {"samples": ["23", 0], "vae": ["4", 0]}},
        "30": {"class_type": "SaveImage", "inputs": {"images": ["24", 0], "filename_prefix": prefix}},
    }


def pick_reshape(source_metrics, candidates):
    """Ktery vystup prepozovani pouzit. `candidates` = [(jmeno, metriky), ...]
    v poradi, jak vznikly. Prvni prijaty (apose_accepted) vyhrava; kdyz
    neprosel zadny, bere se ten s nejvetsi mezerou zapesti, ale jen pokud je
    lepsi nez zdroj - jinak None (= nechat zdroj, prepozovani nepomohlo)."""
    for name, m in candidates:
        if apose_accepted(m):
            return name
    best = max(candidates, key=lambda c: apose_score(c[1]), default=None)
    if best is None or apose_score(best[1]) <= apose_score(source_metrics):
        return None
    return best[0]
