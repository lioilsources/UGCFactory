"""Testy fc_pose.py bez ComfyUI - ciste funkce (metriky, brany, grafy).

    python3 -m unittest discover -s worker -p 'fc_*_test.py'
"""
import struct
import sys
import os
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import fc_pose  # noqa: E402


# Sablona 18 kloubu, vsechny s vysokou confidence: A-poza, kotniky videt.
# Poradi: nos,krk,Rrameno,Rloket,Rzapesti,Lrameno,Lloket,Lzapesti,Rbok,Rkoleno,
# Rkotnik,Lbok,Lkoleno,Lkotnik,Roko,Loko,Rucho,Lucho.
def _apose_kps():
    return [
        (100, 20, 0.9),     # 0 nos
        (100, 60, 0.9),     # 1 krk
        (60, 65, 0.9),      # 2 R rameno
        (30, 100, 0.9),     # 3 R loket
        (10, 130, 0.9),     # 4 R zapesti (dale od osy - A-poza)
        (140, 65, 0.9),     # 5 L rameno
        (170, 100, 0.9),    # 6 L loket
        (190, 130, 0.9),    # 7 L zapesti
        (85, 220, 0.9),     # 8 R bok
        (85, 340, 0.9),     # 9 R koleno
        (85, 460, 0.9),     # 10 R kotnik (1.5 trupu pod boky - skutecny)
        (115, 220, 0.9),    # 11 L bok
        (115, 340, 0.9),    # 12 L koleno
        (115, 460, 0.9),    # 13 L kotnik
        (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    ]


def _fused_kps():
    """Ruce podel tela (zapesti skoro na ose trupu), kotniky pod ramem."""
    kps = _apose_kps()
    kps[4] = (78, 130, 0.9)    # R zapesti tesne u osy
    kps[7] = (122, 130, 0.9)   # L zapesti tesne u osy
    kps[10] = (0, 0, 0.05)     # kotniky neviditelne (pod ramem fotky)
    kps[13] = (0, 0, 0.05)
    return kps


class TestPoseMetrics(unittest.TestCase):
    def test_apose_has_wide_wrist_gap_and_visible_ankles(self):
        m = fc_pose.pose_metrics(_apose_kps())
        self.assertNotIn("error", m)
        self.assertGreater(m["wrist_gap_min"], 0.85)
        self.assertTrue(m["ankles_visible"])
        self.assertFalse(fc_pose.needs_arm_reshape(m))
        self.assertFalse(fc_pose.needs_leg_outpaint(m))

    def test_fused_arms_and_missing_ankles_trigger_both_gates(self):
        m = fc_pose.pose_metrics(_fused_kps())
        self.assertLess(m["wrist_gap_min"], fc_pose.APOSE_MIN_WRIST_GAP)
        self.assertFalse(m["ankles_visible"])
        self.assertTrue(fc_pose.needs_arm_reshape(m))
        self.assertTrue(fc_pose.needs_leg_outpaint(m))

    def test_confident_ankles_too_close_to_the_hips_are_not_ankles(self):
        # fotka useknuta v pulce stehen: DWPose dal kotniky s confidence 1.0
        # kousek pod boky (0.9 trupu; trup = 160 px) - musi se outpaintovat
        kps = _apose_kps()
        kps[10] = (85, 220 + 0.9 * 160, 1.0)
        kps[13] = (115, 220 + 0.9 * 160, 1.0)
        m = fc_pose.pose_metrics(kps)
        self.assertAlmostEqual(m["leg_ratio"], 0.9, places=1)
        self.assertFalse(m["ankles_visible"])
        self.assertNotIn("ankle_spread", m)
        self.assertTrue(fc_pose.needs_leg_outpaint(m))

    def test_missing_hips_or_shoulders_is_an_error(self):
        kps = _apose_kps()
        kps[8] = (85, 220, 0.05)  # R bok pod prahem
        m = fc_pose.pose_metrics(kps)
        self.assertIn("error", m)
        self.assertFalse(fc_pose.needs_arm_reshape(m))
        self.assertFalse(fc_pose.needs_leg_outpaint(m))

    def test_one_arm_missing_still_gives_a_gap_from_the_other(self):
        kps = _apose_kps()
        kps[6] = (0, 0, 0.1)  # L loket chybi
        kps[7] = (0, 0, 0.1)  # L zapesti chybi
        m = fc_pose.pose_metrics(kps)
        self.assertIn("wrist_gap_min", m)   # z prave paze


class TestGates(unittest.TestCase):
    def test_only_a_finished_apose_skips_the_reshape(self):
        m = {"arm_angle_deg": fc_pose.APOSE_MIN_ARM_ANGLE, "wrist_gap_min": fc_pose.APOSE_MIN_WRIST_GAP}
        self.assertFalse(fc_pose.needs_arm_reshape(m))
        self.assertTrue(fc_pose.needs_arm_reshape({**m, "arm_angle_deg": 17.9}))
        self.assertTrue(fc_pose.needs_arm_reshape({**m, "wrist_gap_min": 0.99}))

    def test_arms_down_along_wide_hips_still_need_reshaping(self):
        # malby z Ol1nLLM 2026-09-16: paze na tele, ale zapesti daleko od osy
        for m in ({"arm_angle_deg": 1.7, "wrist_gap_min": 1.33},
                  {"arm_angle_deg": 2.0, "wrist_gap_min": 1.32}):
            self.assertTrue(fc_pose.needs_arm_reshape(m))

    def test_unmeasurable_arms_are_left_alone(self):
        # bez pazi by vysledek nesel zkontrolovat, tak se ani neprepozovava
        self.assertFalse(fc_pose.needs_arm_reshape({"shoulder_w": 100.0, "ankles_visible": True}))
        self.assertFalse(fc_pose.needs_arm_reshape({"wrist_gap_min": 0.3}))

    def test_error_metrics_never_trigger_either_gate(self):
        m = {"error": "chybi ramena nebo boky"}
        self.assertFalse(fc_pose.needs_arm_reshape(m))
        self.assertFalse(fc_pose.needs_leg_outpaint(m))


class TestAposeAcceptance(unittest.TestCase):
    # hodnoty z mereni 2026-09-16 (DWPose na vystupech Kontextu)
    def test_needs_both_angle_and_wrist_gap(self):
        self.assertTrue(fc_pose.apose_accepted({"arm_angle_deg": 24.2, "wrist_gap_min": 1.18}))   # shorts
        self.assertTrue(fc_pose.apose_accepted({"arm_angle_deg": 18.2, "wrist_gap_min": 1.02}))   # busty blonde
        self.assertFalse(fc_pose.apose_accepted({"arm_angle_deg": 13.1, "wrist_gap_min": 0.95}))  # Teresa: paze u tela
        self.assertFalse(fc_pose.apose_accepted({"arm_angle_deg": 41.5, "wrist_gap_min": 0.68}))  # albine: ruce na bocich
        self.assertFalse(fc_pose.apose_accepted({"arm_angle_deg": 10.4, "wrist_gap_min": 1.06}))  # mezera ano, uhel ne

    def test_error_or_missing_arms_is_rejected(self):
        self.assertFalse(fc_pose.apose_accepted({"error": "chybi ramena nebo boky"}))
        self.assertFalse(fc_pose.apose_accepted({"shoulder_w": 100.0, "ankles_visible": True}))

    def test_score_prefers_the_wider_wrist_gap_and_sinks_errors(self):
        cands = [{"error": "x"}, {"wrist_gap_min": 0.58}, {"wrist_gap_min": 0.95}]
        self.assertEqual(max(cands, key=fc_pose.apose_score), cands[2])
        self.assertLess(fc_pose.apose_score(cands[0]), fc_pose.apose_score(cands[1]))


class TestBarBounds(unittest.TestCase):
    # std radku z mereni 2026-09-16: pruh 0, fotka 14-55
    def test_black_player_bar_at_the_bottom_is_cut(self):
        rows = [16.0] * 919 + [0.0] * 105          # tanecnice: 1024 radku, dole 105 cernych
        self.assertEqual(fc_pose.bar_bounds(rows, 1024), (0, 105))

    def test_status_strip_at_the_top_is_cut(self):
        rows = [0.0] * 64 + [21.0] * 2372          # silonky: nahore 64 cernych z 2436
        self.assertEqual(fc_pose.bar_bounds(rows, 2436), (64, 0))

    def test_short_flat_band_is_a_compression_artifact_not_a_bar(self):
        rows = [0.0] * 5 + [40.0] * 1000           # 0.5 % vysky -> nechat
        self.assertEqual(fc_pose.bar_bounds(rows, 1005), (0, 0))

    def test_entirely_flat_image_is_left_alone(self):
        self.assertEqual(fc_pose.bar_bounds([0.0] * 100, 100), (0, 0))

    def test_photo_rows_never_count_as_bars(self):
        self.assertEqual(fc_pose.bar_bounds([14.0] * 50 + [54.0] * 50, 100), (0, 0))


class TestOutpaintBottom(unittest.TestCase):
    def test_rounds_up_to_a_multiple_of_16(self):
        # floor_y = hip_y(1000) + 2.2*torso(300) = 1660; vyska obrazku 1400
        # -> chybi presne 260 px, zaokrouhlit nahoru na 16 = 272
        px = fc_pose.outpaint_bottom_px({"hip_y": 1000.0, "torso": 300.0}, 1400)
        self.assertEqual(px, 272)
        self.assertEqual(px % 16, 0)

    def test_floor_already_inside_the_image_needs_nothing(self):
        px = fc_pose.outpaint_bottom_px({"hip_y": 500.0, "torso": 100.0}, 2000)
        self.assertEqual(px, 0)


class TestParseKeypoints(unittest.TestCase):
    def _frame(self, canvas=(200, 400)):
        cw, ch = canvas
        flat = []
        for i in range(18):
            flat += [10.0 * i, 20.0 * i, 0.8]
        return {"people": [{"pose_keypoints_2d": flat}], "canvas_width": cw, "canvas_height": ch}

    def test_rescales_from_dwpose_canvas_to_real_pixels(self):
        # DWPose canvas 200x400, skutecny obrazek 400x800 (2x vetsi) -> body 2x
        kps = fc_pose.parse_pose_keypoints(self._frame((200, 400)), 400, 800)
        self.assertEqual(len(kps), 18)
        self.assertAlmostEqual(kps[1][0], 10.0 * 2)  # bod 1: x=10 -> 20
        self.assertAlmostEqual(kps[1][1], 20.0 * 2)

    def test_accepts_the_list_of_frames_wrapper_too(self):
        kps = fc_pose.parse_pose_keypoints([self._frame()], 200, 400)
        self.assertEqual(len(kps), 18)

    def test_no_people_means_dwpose_found_nobody(self):
        self.assertIsNone(fc_pose.parse_pose_keypoints({"people": [], "canvas_width": 1, "canvas_height": 1}, 1, 1))


class TestImageSize(unittest.TestCase):
    def _png_bytes(self, w, h):
        sig = b"\x89PNG\r\n\x1a\n"
        ihdr = struct.pack(">I", 13) + b"IHDR" + struct.pack(">II", w, h) + bytes(5) + struct.pack(">I", 0)
        return sig + ihdr

    def _jpeg_bytes(self, w, h, with_app0=False):
        sof0 = b"\xff\xc0" + b"\x00\x00\x08" + struct.pack(">HH", h, w)  # SOF0 uklada vysku pred sirkou
        if not with_app0:
            return b"\xff\xd8" + sof0
        payload = b"JFIF" + bytes(9)
        app0 = b"\xff\xe0" + struct.pack(">H", 2 + len(payload)) + payload
        return b"\xff\xd8" + app0 + sof0

    def test_png_dimensions(self):
        path = _write(self._png_bytes(800, 600))
        self.assertEqual(fc_pose.image_size(path), (800, 600))

    def test_jpeg_dimensions(self):
        path = _write(self._jpeg_bytes(1024, 768))
        self.assertEqual(fc_pose.image_size(path), (1024, 768))

    def test_jpeg_skips_segments_before_sof0(self):
        path = _write(self._jpeg_bytes(640, 480, with_app0=True))
        self.assertEqual(fc_pose.image_size(path), (640, 480))

    def test_neither_png_nor_jpeg_raises(self):
        path = _write(b"not an image")
        with self.assertRaises(RuntimeError):
            fc_pose.image_size(path)


def _write(data):
    import tempfile
    fd, path = tempfile.mkstemp()
    with os.fdopen(fd, "wb") as f:
        f.write(data)
    return path


class TestGraphs(unittest.TestCase):
    def test_pose_graph_wires_the_uploaded_image_and_bbox(self):
        g = fc_pose.pose_graph("fc/img.png", "fc/pose", bbox_detector="None")
        self.assertEqual(g["1"]["inputs"]["image"], "fc/img.png")
        self.assertEqual(g["2"]["class_type"], "DWPreprocessor")
        self.assertEqual(g["2"]["inputs"]["bbox_detector"], "None")
        self.assertEqual(g["3"]["class_type"], "SavePoseKpsAsJsonFile")
        self.assertEqual(g["3"]["inputs"]["filename_prefix"], "fc/pose")

    def test_outpaint_graph_sets_bottom_and_prompt(self):
        g = fc_pose.outpaint_graph("fc/img.png", 128, "grow legs", 7, "fc/out")
        self.assertEqual(g["31"]["inputs"]["bottom"], 128)
        self.assertEqual(g["31"]["inputs"]["left"], 0)
        self.assertEqual(g["14"]["inputs"]["text"], "grow legs")
        self.assertEqual(g["18"]["inputs"]["seed"], 7)

    def test_kontext_graph_wires_prompt_and_seed(self):
        g = fc_pose.kontext_graph("fc/img.png", "A-pose", 11, "fc/apose")
        self.assertEqual(g["8"]["inputs"]["text"], "A-pose")
        self.assertEqual(g["12"]["inputs"]["seed"], 11)
        self.assertEqual(g["20"]["inputs"]["filename_prefix"], "fc/apose")

    def test_repose_graph_wires_reference_driver_and_retarget(self):
        g = fc_pose.repose_graph("ref.png", "driver.png", 11, "fc/repose")
        self.assertEqual(g["6"]["inputs"]["image"], "ref.png")
        self.assertEqual(g["7"]["inputs"]["image"], "driver.png")
        self.assertEqual(g["11"]["inputs"]["retarget_image"], ["8", 0])   # kostra na proporce reference
        self.assertEqual(g["17"]["inputs"]["length"], fc_pose.REPOSE_FRAMES)
        self.assertEqual(g["13"]["inputs"]["amount"], fc_pose.REPOSE_FRAMES)
        self.assertEqual(g["18"]["inputs"]["noise_seed"], 11)
        self.assertEqual(g["30"]["inputs"]["filename_prefix"], "fc/repose")
        # bez retargetu se reference do detekce vubec nezapoji
        self.assertNotIn("retarget_image", fc_pose.repose_graph("r", "d", 1, "p", retarget=False)["11"]["inputs"])


class TestPickReshape(unittest.TestCase):
    SRC = {"arm_angle_deg": 12.0, "wrist_gap_min": 0.70}   # Teresa pred opravou

    def test_first_accepted_candidate_wins_without_looking_further(self):
        cands = [("wan_repose", {"arm_angle_deg": 45.5, "wrist_gap_min": 1.75}),
                 ("kontext_apose", {"arm_angle_deg": 24.0, "wrist_gap_min": 1.9})]
        self.assertEqual(fc_pose.pick_reshape(self.SRC, cands), "wan_repose")

    def test_unaccepted_but_wider_than_source_is_still_used(self):
        cands = [("wan_repose", {"error": "ComfyUI: chybi model"}),
                 ("kontext_apose", {"arm_angle_deg": 13.1, "wrist_gap_min": 0.95})]
        self.assertEqual(fc_pose.pick_reshape(self.SRC, cands), "kontext_apose")

    def test_nothing_better_than_source_means_keep_source(self):
        cands = [("wan_repose", {"error": "x"}),
                 ("kontext_apose", {"arm_angle_deg": 6.7, "wrist_gap_min": 0.58})]
        self.assertIsNone(fc_pose.pick_reshape(self.SRC, cands))
        self.assertIsNone(fc_pose.pick_reshape(self.SRC, []))


if __name__ == "__main__":
    unittest.main()
