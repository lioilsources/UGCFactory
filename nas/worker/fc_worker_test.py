"""Testy casti FC workeru, ktere nepotrebuji Blender ani ComfyUI:

    python3 -m unittest discover -s worker -p 'fc_*_test.py'

Blenderove a ComfyUI kroky se takhle otestovat nedaji - ty overuje az
golden test v kontejneru, resp. beh proti Sparku.
"""
import json
import math
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "blender_scripts"))

import fc_worker  # noqa: E402
from fc_ranges import lua_table, normalize  # noqa: E402


class TestTitleContract(unittest.TestCase):
    """Workflow se s workerem domlouva pres titulky nodu, ne cisla - cisla se
    pri kazde editaci grafu v ComfyUI premichaji."""

    def test_sets_input_on_titled_node(self):
        wf = {
            "3": {"class_type": "LoadImage", "_meta": {"title": "FC_INPUT_IMAGE"},
                  "inputs": {"image": "old.png"}},
            "4": {"class_type": "SaveImage", "_meta": {"title": "out"}, "inputs": {}},
        }
        hits = fc_worker.set_titled_input(wf, "FC_INPUT_IMAGE", "image", "/data/new.png")
        self.assertEqual(hits, 1)
        self.assertEqual(wf["3"]["inputs"]["image"], "/data/new.png")
        self.assertEqual(wf["4"]["inputs"], {})

    def test_missing_title_reports_zero(self):
        wf = {"3": {"class_type": "LoadImage", "_meta": {"title": "jine"}, "inputs": {}}}
        self.assertEqual(fc_worker.set_titled_input(wf, "FC_INPUT_IMAGE", "image", "x"), 0)


class TestOutputs(unittest.TestCase):
    def test_collects_across_nodes_and_keys(self):
        outputs = {
            "9": {"images": [{"filename": "apose.png", "subfolder": "fc", "type": "output"}]},
            "12": {"gltf": [{"filename": "mesh.glb", "subfolder": "", "type": "output"}]},
        }
        got = fc_worker.collect_outputs(outputs)
        self.assertIn(("apose.png", "fc", "output"), got)
        self.assertIn(("mesh.glb", "", "output"), got)

    def test_pick_by_extension(self):
        files = [("a.png", "", "output"), ("b.glb", "", "output")]
        self.assertEqual(fc_worker.pick_output(files, ".glb")[0], "b.glb")

    def test_pick_raises_with_what_it_saw(self):
        with self.assertRaises(RuntimeError) as ctx:
            fc_worker.pick_output([("a.png", "", "output")], ".fbx")
        self.assertIn("a.png", str(ctx.exception))


class TestWorkflowLookup(unittest.TestCase):
    def test_missing_workflow_points_at_phase_one(self):
        fc_worker.WORKFLOW_DIR = tempfile.mkdtemp()
        with self.assertRaises(RuntimeError) as ctx:
            fc_worker.load_workflow("char.rig")
        msg = str(ctx.exception)
        self.assertIn("fc_rig.json", msg)
        self.assertIn("faze 1", msg)

    def test_falls_back_to_pipeline_json(self):
        d = tempfile.mkdtemp()
        with open(os.path.join(d, "fc_pipeline.json"), "w") as f:
            json.dump({"1": {"class_type": "LoadImage"}}, f)
        fc_worker.WORKFLOW_DIR = d
        wf, name = fc_worker.load_workflow("char.mesh")
        self.assertEqual(name, "fc_pipeline.json")
        self.assertIn("1", wf)


class TestSlug(unittest.TestCase):
    def test_name_becomes_filesystem_safe(self):
        self.assertEqual(fc_worker.safe_slug({"id": "x", "name": "Sir Testalot!"}), "sir_testalot")

    def test_falls_back_to_id(self):
        self.assertEqual(fc_worker.safe_slug({"id": "abc123", "name": "???"}), "abc123")


class TestLuaRanges(unittest.TestCase):
    def test_table_is_sorted_and_quoted(self):
        lua = lua_table("knight", {"walk": [65, 125], "idle_01": [1, 60]})
        self.assertIn('["idle_01"] = {x = 1, y = 60},', lua)
        self.assertIn('["walk"] = {x = 65, y = 125},', lua)
        self.assertLess(lua.index("idle_01"), lua.index("walk"))
        self.assertTrue(lua.rstrip().endswith("}"))

    def test_degenerate_ranges_dropped(self):
        # prazdny interval by mob ve hre zamrznul na jednom snimku
        self.assertEqual(normalize({"a": [10, 10], "b": [5, 1], "c": [1, 2], "d": [3]}),
                         {"c": (1, 2)})


class TestLoadRanges(unittest.TestCase):
    def test_reads_retarget_output(self):
        d = tempfile.mkdtemp()
        with open(os.path.join(d, "retarget_ranges.json"), "w") as f:
            json.dump({"ranges": {"idle_01": [1, 60]}}, f)
        self.assertEqual(fc_worker.load_ranges(d), {"idle_01": [1, 60]})

    def test_missing_file_is_empty(self):
        self.assertEqual(fc_worker.load_ranges(tempfile.mkdtemp()), {})


class TestComfyUpload(unittest.TestCase):
    """Soubory kroku lezi na /data JODA, ComfyUI bezi na Sparku a sdileny
    mount mezi nimi neni - workflow proto musi dostat jmeno nahraneho souboru,
    nikdy ne absolutni cestu."""

    def test_uploads_and_uses_returned_name(self):
        sent = {}

        def fake_urlopen(req, *a, **kw):
            sent["url"] = req.full_url
            sent["ctype"] = req.headers.get("Content-type", "")
            sent["body"] = req.data

            class Resp:
                def read(self_inner):
                    return b'{"name": "fc_abc_source.png", "subfolder": "", "type": "input"}'

                def __enter__(self_inner):
                    return self_inner

                def __exit__(self_inner, *exc):
                    return False

            return Resp()

        with tempfile.TemporaryDirectory() as d:
            src_path = os.path.join(d, "source.png")
            with open(src_path, "wb") as f:
                f.write(b"\x89PNG_fake")
            orig_open, orig_comfy = fc_worker.urllib.request.urlopen, fc_worker.COMFY
            fc_worker.urllib.request.urlopen = fake_urlopen
            fc_worker.COMFY = "http://spark:8188"
            try:
                name = fc_worker.comfy_upload(src_path)
            finally:
                fc_worker.urllib.request.urlopen = orig_open
                fc_worker.COMFY = orig_comfy

        self.assertEqual(name, "fc_abc_source.png")
        self.assertEqual(sent["url"], "http://spark:8188/upload/image")
        self.assertIn("multipart/form-data", sent["ctype"])
        self.assertIn(b"\x89PNG_fake", sent["body"])
        # Jmeno v ComfyUI musi byt unikatni, jinak si soubezne joby prepisou vstup.
        self.assertNotIn(b'filename="source.png"', sent["body"])

    def test_subfolder_is_part_of_the_name(self):
        def fake_urlopen(req, *a, **kw):
            class Resp:
                def read(self_inner):
                    return b'{"name": "x.png", "subfolder": "fc", "type": "input"}'

                def __enter__(self_inner):
                    return self_inner

                def __exit__(self_inner, *exc):
                    return False

            return Resp()

        with tempfile.TemporaryDirectory() as d:
            src_path = os.path.join(d, "x.png")
            with open(src_path, "wb") as f:
                f.write(b"x")
            orig_open, orig_comfy = fc_worker.urllib.request.urlopen, fc_worker.COMFY
            fc_worker.urllib.request.urlopen = fake_urlopen
            fc_worker.COMFY = "http://spark:8188"
            try:
                self.assertEqual(fc_worker.comfy_upload(src_path), "fc/x.png")
            finally:
                fc_worker.urllib.request.urlopen = orig_open
                fc_worker.COMFY = orig_comfy


class TestComfyOutage(unittest.TestCase):
    """Spark si delime s dalsimi klienty; kdyz se ComfyUI restartuje,
    odpovida Connection refused. 2026-09-17 to za tri minuty shodilo 13
    postav v rade - krok proto pocka, nez se zvedne."""

    def setUp(self):
        self.saved = {n: getattr(fc_worker, n) for n in ("COMFY", "COMFY_RETRIES",
                                                         "COMFY_RETRY_DELAY")}
        fc_worker.COMFY = "http://spark:8188"
        fc_worker.COMFY_RETRIES, fc_worker.COMFY_RETRY_DELAY = 3, 0
        self.orig_open, self.orig_sleep = fc_worker.urllib.request.urlopen, fc_worker.time.sleep
        fc_worker.time.sleep = lambda s: None

    def tearDown(self):
        for n, v in self.saved.items():
            setattr(fc_worker, n, v)
        fc_worker.urllib.request.urlopen = self.orig_open
        fc_worker.time.sleep = self.orig_sleep

    def fake(self, failures, payload=b'{"ok": 1}'):
        """urlopen, ktery prvnich `failures` volani spadne na vypadku."""
        state = {"n": 0}

        class Resp:
            status = 200

            def read(self_inner, *a):
                return payload

            def __enter__(self_inner):
                return self_inner

            def __exit__(self_inner, *exc):
                return False

        def opener(req, *a, **kw):
            state["n"] += 1
            if state["n"] <= failures:
                raise fc_worker.urllib.error.URLError("[Errno 111] Connection refused")
            return Resp()

        fc_worker.urllib.request.urlopen = opener
        return state

    def test_get_waits_out_a_restart(self):
        state = self.fake(2)                 # spadne pri volani i pri prvni kontrole
        self.assertEqual(fc_worker.comfy_get("/history/x"), {"ok": 1})
        self.assertGreater(state["n"], 2)

    def test_gives_up_after_the_last_attempt(self):
        self.fake(99)
        with self.assertRaises(RuntimeError) as ctx:
            fc_worker.comfy_get("/queue")
        self.assertIn("nedostupne", str(ctx.exception))

    def test_http_error_is_not_an_outage(self):
        def opener(req, *a, **kw):
            raise fc_worker.urllib.error.HTTPError("u", 400, "Bad Request", {}, None)
        fc_worker.urllib.request.urlopen = opener
        with self.assertRaises(fc_worker.urllib.error.HTTPError):
            fc_worker.comfy_open("http://spark:8188/queue", 10)

    def test_empty_body_during_restart_is_retried_not_swallowed(self):
        """2026-09-19: ComfyUI behem restartu prijme spojeni a vrati 200
        s prazdnym telem drive, nez je fakt pripravene - urlopen() tedy
        uspeje a json.load() spadne mimo comfy_open. step_preprocess bral
        tenhle pad jako nefatalni a tise pokracoval bez opravy pozy (legless
        mesh bez chybove hlasky u postavy) - comfy_json to musi precekat."""
        calls = {"n": 0}

        class EmptyResp:
            status = 200

            def read(self_inner, *a):
                return b""

            def __enter__(self_inner):
                return self_inner

            def __exit__(self_inner, *exc):
                return False

        class OkResp:
            status = 200

            def read(self_inner, *a):
                return b'{"ok": 1}'

            def __enter__(self_inner):
                return self_inner

            def __exit__(self_inner, *exc):
                return False

        def opener(req, *a, **kw):
            calls["n"] += 1
            return EmptyResp() if calls["n"] == 1 else OkResp()

        fc_worker.urllib.request.urlopen = opener
        self.assertEqual(fc_worker.comfy_get("/history/x"), {"ok": 1})
        self.assertGreaterEqual(calls["n"], 2)

    def test_garbage_body_that_never_recovers_still_raises(self):
        def opener(req, *a, **kw):
            class Resp:
                status = 200

                def read(self_inner, *a):
                    return b"not json"

                def __enter__(self_inner):
                    return self_inner

                def __exit__(self_inner, *exc):
                    return False
            return Resp()
        fc_worker.urllib.request.urlopen = opener
        with self.assertRaises(ValueError):
            fc_worker.comfy_get("/history/x")


class TestPrefixCandidates(unittest.TestCase):
    """Trellis2ExportMesh nezapise do history nic, takze se soubor musi
    odhadnout z filename_prefix - jinak by krok mesh spadl vzdycky."""

    def test_derives_path_from_prefix_and_format(self):
        wf = {"10": {"class_type": "Trellis2ExportMesh",
                     "inputs": {"filename_prefix": "3D/fc_mesh", "file_format": "glb"}}}
        self.assertEqual(fc_worker.prefix_candidates(wf),
                         [("fc_mesh_00001_.glb", "3D", "output")])

    def test_prefix_without_subfolder(self):
        wf = {"3": {"class_type": "SaveImage", "inputs": {"filename_prefix": "apose"}}}
        self.assertIn(("apose_00001_.png", "", "output"), fc_worker.prefix_candidates(wf))

    def test_ignores_nodes_without_prefix(self):
        wf = {"1": {"class_type": "LoadImage", "inputs": {"image": "x.png"}}}
        self.assertEqual(fc_worker.prefix_candidates(wf), [])


class TestUniqueOutputs(unittest.TestCase):
    """Se sdilenym prefixem ukazoval odhad _00001_ na vystup prvni postavy,
    takze kazda dalsi fotka dostala jeji mesh."""

    def test_each_run_guesses_its_own_file(self):
        base = {"10": {"class_type": "Trellis2ExportMesh",
                       "inputs": {"filename_prefix": "3D/fc_mesh", "file_format": "glb"}}}
        guesses = []
        for token in ("aaa", "bbb"):
            wf = json.loads(json.dumps(base))
            fc_worker.unique_outputs(wf, token)
            guesses.append(fc_worker.prefix_candidates(wf)[0])
        self.assertEqual(guesses[0], ("fc_mesh_aaa_00001_.glb", "3D", "output"))
        self.assertNotEqual(guesses[0], guesses[1])

    def test_mia_fbx_name_is_unique_too(self):
        wf = {"3": {"class_type": "MIAAutoRig", "inputs": {"fbx_name": "fc_rig"}}}
        fc_worker.unique_outputs(wf, "ccc")
        self.assertIn(("fc_rig_ccc_mia.fbx", "", "output"), fc_worker.prefix_candidates(wf))

    def test_leaves_other_inputs_alone(self):
        wf = {"1": {"_meta": {"title": "FC_INPUT_IMAGE"}, "inputs": {"image": "x.png"}},
              "2": "neni nod"}
        fc_worker.unique_outputs(wf, "ddd")
        self.assertEqual(wf["1"]["inputs"], {"image": "x.png"})


class TestInputKeyByNode(unittest.TestCase):
    """Vstupni parametr se jmenuje podle nodu - LoadImage "image",
    UniRigLoadMesh "file_path". Titulek urcuje nod, ne parametr."""

    def test_loadimage_uses_image(self):
        wf = {"1": {"_meta": {"title": "FC_INPUT_IMAGE"},
                    "inputs": {"image": "old.png", "upload": "image"}}}
        self.assertEqual(fc_worker.set_titled_source(wf, "FC_INPUT_IMAGE", "new.png"), 1)
        self.assertEqual(wf["1"]["inputs"]["image"], "new.png")

    def test_loadmesh_uses_file_path(self):
        wf = {"1": {"_meta": {"title": "FC_INPUT_IMAGE"},
                    "inputs": {"source_folder": "input", "file_path": "old.glb"}}}
        fc_worker.set_titled_source(wf, "FC_INPUT_IMAGE", "new.glb")
        self.assertEqual(wf["1"]["inputs"]["file_path"], "new.glb")
        self.assertEqual(wf["1"]["inputs"]["source_folder"], "input")
        self.assertNotIn("image", wf["1"]["inputs"])

    def test_no_titled_node_is_reported(self):
        wf = {"1": {"_meta": {"title": "neco jineho"}, "inputs": {"image": "x"}}}
        self.assertEqual(fc_worker.set_titled_source(wf, "FC_INPUT_IMAGE", "y"), 0)


if __name__ == "__main__":
    unittest.main()


class TestChooseRig(unittest.TestCase):
    """Auto rezim bere rig s mensim natazenim hran; na peti postavach tim
    vyhrala MIA u fotek cele postavy a sablona u rytire a orezanych postav."""

    def test_lower_stretch_wins(self):
        c = {"template": {"score": {"stretch_mean": 1.33}}, "mia": {"score": {"stretch_mean": 1.20}}}
        self.assertEqual(fc_worker.choose_rig(c), "mia")
        c["template"]["score"]["stretch_mean"] = 1.23
        c["mia"]["score"]["stretch_mean"] = 1.59
        self.assertEqual(fc_worker.choose_rig(c), "template")

    def test_tie_goes_to_template(self):
        c = {"mia": {"score": {"stretch_mean": 1.3}}, "template": {"score": {"stretch_mean": 1.3}}}
        self.assertEqual(fc_worker.choose_rig(c), "template")

    def test_failed_rig_never_wins(self):
        c = {"template": {"score": {"stretch_mean": 1.9}}, "mia": {"error": "ComfyUI nedobehl"}}
        self.assertEqual(fc_worker.choose_rig(c), "template")

    def test_scored_beats_unscored(self):
        c = {"template": {"score_error": "retarget selhal"}, "mia": {"score": {"stretch_mean": 1.5}}}
        self.assertEqual(fc_worker.choose_rig(c), "mia")

    def test_nothing_scored_prefers_template(self):
        self.assertEqual(fc_worker.choose_rig({"template": {}, "mia": {}}), "template")

    def test_all_failed_is_none(self):
        self.assertIsNone(fc_worker.choose_rig({"template": {"error": "x"}, "mia": {"error": "y"}}))

    def test_misaligned_rest_pose_loses_even_with_lower_stretch(self):
        # tancici figurka 2026-09-16: MIA melo mensi natazeni, ale klidovou
        # pozu 26.7 stupne od Mixama - v animaci se hrbila
        c = {"template": {"score": {"stretch_mean": 1.133, "rest_offset_deg": 3.9}},
             "mia": {"score": {"stretch_mean": 1.108, "rest_offset_deg": 26.7}}}
        self.assertEqual(fc_worker.choose_rig(c), "template")

    def test_aligned_rest_pose_still_decided_by_stretch(self):
        c = {"template": {"score": {"stretch_mean": 1.33, "rest_offset_deg": 3.9}},
             "mia": {"score": {"stretch_mean": 1.20, "rest_offset_deg": 7.0}}}
        self.assertEqual(fc_worker.choose_rig(c), "mia")

    def test_all_misaligned_falls_back_to_stretch(self):
        c = {"template": {"score": {"stretch_mean": 1.40, "rest_offset_deg": 21.0}},
             "mia": {"score": {"stretch_mean": 1.20, "rest_offset_deg": 26.7}}}
        self.assertEqual(fc_worker.choose_rig(c), "mia")

    def test_missing_measurement_does_not_disqualify(self):
        # starsi postavy a fixture bez rest_offset_deg se chovaji jako driv
        c = {"template": {"score": {"stretch_mean": 1.33}},
             "mia": {"score": {"stretch_mean": 1.20}}}
        self.assertEqual(fc_worker.choose_rig(c), "mia")


class TestStepRigAuto(unittest.TestCase):
    """Orchestrace auto rezimu bez Blenderu a ComfyUI: stavebni kroky jsou
    nahrazene a zapisuji jen soubory, ktere by zapsaly skutecne skripty."""

    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.claim = {"dir": self.dir, "character": {"id": "c1"},
                      "files": {"clean_glb": "clean.glb", "rigged_fbx": "rigged.fbx"},
                      "clips": [{"id": "zombie_walk", "fbx_path": "/data/animlib/Zombie Walk.fbx"}]}
        self.saved = {n: getattr(fc_worker, n) for n in ("rig_template", "rig_mia", "score_rig", "RIG_MODE")}
        fc_worker.RIG_MODE = "auto"

    def tearDown(self):
        for n, v in self.saved.items():
            setattr(fc_worker, n, v)

    def fake_builder(self, tag, fail=None):
        def build(claim, out, *timeout):
            if fail:
                raise RuntimeError(fail)
            with open(os.path.join(out, "rigged.fbx"), "w") as f:
                f.write(tag)
            with open(os.path.join(out, "rig_report.json"), "w") as f:
                json.dump({"weights": tag}, f)
            return {"weights": tag}
        return build

    def run_rig(self, scores):
        fc_worker.score_rig = lambda claim, out, clip: {"stretch_mean": scores[os.path.basename(out)]}
        result = fc_worker.step_rig(self.claim)
        with open(os.path.join(self.dir, "rigged.fbx")) as f:
            fbx = f.read()
        with open(os.path.join(self.dir, "rig_report.json")) as f:
            report = json.load(f)
        return result, fbx, report

    def test_better_scoring_rig_is_installed(self):
        fc_worker.rig_template = self.fake_builder("heat")
        fc_worker.rig_mia = self.fake_builder("mia")
        _, fbx, report = self.run_rig({"rig_template": 1.33, "rig_mia": 1.20})
        self.assertEqual(fbx, "mia")
        self.assertEqual(report["rig_choice"], "mia")
        self.assertEqual(report["weights"], "mia")
        self.assertEqual(report["rig_clip"], "zombie_walk")
        self.assertEqual(report["rig_scores"]["template"]["stretch_mean"], 1.33)

    def test_mia_failure_falls_back_to_template(self):
        fc_worker.rig_template = self.fake_builder("heat")
        fc_worker.rig_mia = self.fake_builder("mia", fail="MIALoadModel: NodeOutput is not JSON serializable")
        result, fbx, report = self.run_rig({"rig_template": 1.9})
        self.assertEqual(fbx, "heat")
        self.assertEqual(report["rig_choice"], "template")
        self.assertIn("NodeOutput", report["rig_scores"]["mia"]["error"])
        self.assertEqual(result["artifacts"]["rigged_fbx"], os.path.join(self.dir, "rigged.fbx"))

    def test_without_clips_template_is_kept(self):
        self.claim["clips"] = []
        fc_worker.rig_template = self.fake_builder("heat")
        fc_worker.rig_mia = self.fake_builder("mia")
        fc_worker.score_rig = lambda *a: self.fail("bez klipu se nema merit")
        fc_worker.step_rig(self.claim)
        with open(os.path.join(self.dir, "rigged.fbx")) as f:
            self.assertEqual(f.read(), "heat")

    def test_both_failing_fails_the_step(self):
        fc_worker.rig_template = self.fake_builder("heat", fail="mesh na sablonu nesedi")
        fc_worker.rig_mia = self.fake_builder("mia", fail="ComfyUI nedobehl")
        with self.assertRaises(RuntimeError) as ctx:
            fc_worker.step_rig(self.claim)
        self.assertIn("ComfyUI nedobehl", str(ctx.exception))


class TestReshapeArms(unittest.TestCase):
    """Orchestrace A-pozy bez ComfyUI: Wan Animate prvni, po nem mereni,
    Kontext jen kdyz Wan neprojde, a kdyz nepomuze nic, zustava zdroj."""

    ACCEPTED = {"arm_angle_deg": 45.5, "wrist_gap_min": 1.75, "ankles_visible": True}
    WEAK = {"arm_angle_deg": 13.1, "wrist_gap_min": 0.95, "ankles_visible": True}
    SRC = {"arm_angle_deg": 12.0, "wrist_gap_min": 0.70}

    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.saved = {n: getattr(fc_worker, n) for n in ("comfy_upload", "comfy_submit", "comfy_fetch", "detect_pose")}
        self.labels = []
        self.by_file = {}          # jmeno stazeneho souboru -> co ma DWPose "namerit"
        self.failing = set()       # popisky jobu, ktere maji spadnout
        fc_worker.comfy_upload = lambda path: "up/" + os.path.basename(path)
        fc_worker.comfy_submit = self.submit
        fc_worker.comfy_fetch = self.fetch
        fc_worker.detect_pose = self.detect

    def tearDown(self):
        for n, v in self.saved.items():
            setattr(fc_worker, n, v)

    def submit(self, graph, label, timeout=None):
        self.labels.append(label)
        if label in self.failing:
            raise RuntimeError(f"ComfyUI: {label} spadl")
        prefix = next(n["inputs"]["filename_prefix"] for n in graph.values() if n["class_type"] == "SaveImage")
        # Wan vraci vic snimku - bere se posledni podle jmena
        return [(f"{prefix}_0000{i}_.png", "fc", "output") for i in (1, 2, 3)]

    def fetch(self, entry, dst):
        with open(dst, "w") as f:
            f.write(entry[0])
        return dst

    def detect(self, out_dir, path, kps_name="pose_kps.json"):
        m = self.by_file[os.path.basename(path)]
        return (fc_pose_kps(m), 100, 200, m.get("people", 1))

    def test_wan_accepted_skips_kontext(self):
        self.by_file["pose_repose.png"] = self.ACCEPTED
        out, stage = fc_worker.reshape_arms(self.dir, "/x/src.png", self.SRC)
        self.assertEqual(os.path.basename(out), "pose_repose.png")
        self.assertEqual(stage["choice"], "wan_repose")
        self.assertEqual(self.labels, ["A-pose (Wan Animate, seed 11)"])
        with open(out) as f:
            self.assertEqual(f.read(), "fc/repose_00003_.png")   # posledni snimek

    def test_wan_failure_falls_back_to_kontext(self):
        self.failing.add("A-pose (Wan Animate, seed 11)")
        self.by_file["pose_apose.png"] = self.WEAK
        out, stage = fc_worker.reshape_arms(self.dir, "/x/src.png", self.SRC)
        self.assertEqual(os.path.basename(out), "pose_apose.png")   # lepsi nez zdroj, i kdyz neprijaty
        self.assertEqual(stage["choice"], "kontext_apose")
        self.assertIn("spadl", stage["candidates"][0]["error"])
        self.assertEqual(self.labels, ["A-pose (Wan Animate, seed 11)", "A-pose (Kontext)"])

    def test_hallucinated_second_person_is_retried_with_another_seed(self):
        # Wan si do prazdneho mista domysli druhou postavu (oblicej misto
        # nohou) - druhy pokus s jinym seedem to obvykle nezopakuje
        self.by_file["pose_repose.png"] = {**self.ACCEPTED, "people": 2}
        self.by_file["pose_repose2.png"] = self.ACCEPTED
        out, stage = fc_worker.reshape_arms(self.dir, "/x/src.png", self.SRC)
        self.assertEqual(os.path.basename(out), "pose_repose2.png")
        self.assertEqual(stage["choice"], "wan_repose_2")
        self.assertEqual(self.labels,
                         ["A-pose (Wan Animate, seed 11)", "A-pose (Wan Animate, seed 23)"])

    def test_two_people_never_win_even_as_a_fallback(self):
        # obrazek s druhou postavou je horsi nez zdroj - z nej by TRELLIS
        # udelal obludu, takze se radsi nechá puvodni fotka
        self.by_file["pose_repose.png"] = {"arm_angle_deg": 48.0, "wrist_gap_min": 1.6, "people": 2}
        self.by_file["pose_repose2.png"] = {"arm_angle_deg": 47.0, "wrist_gap_min": 1.5, "people": 2}
        self.by_file["pose_apose.png"] = {"error": "chybi ramena nebo boky"}
        out, stage = fc_worker.reshape_arms(self.dir, "/x/src.png", self.SRC)
        self.assertEqual(out, "/x/src.png")
        self.assertIsNone(stage["choice"])

    def test_nothing_better_keeps_the_source(self):
        self.by_file["pose_repose.png"] = {"arm_angle_deg": 6.7, "wrist_gap_min": 0.58}
        self.by_file["pose_apose.png"] = {"error": "chybi ramena nebo boky"}
        out, stage = fc_worker.reshape_arms(self.dir, "/x/src.png", self.SRC)
        self.assertEqual(out, "/x/src.png")
        self.assertIsNone(stage["choice"])
        self.assertEqual([c["name"] for c in stage["candidates"]], ["wan_repose", "kontext_apose"])


def fc_pose_kps(metrics):
    """18 kloubu, ktere fc_pose.pose_metrics prelozi zpet na dane metriky
    (ramena 100 px od sebe, osa trupu svisla; "error" = boky bez confidence)."""
    kps = [(0, 0, 0.0)] * 18
    kps[1] = (100, 60, 0.9)
    kps[2], kps[5] = (50, 65, 0.9), (150, 65, 0.9)
    if "error" in metrics:
        return kps
    kps[8], kps[11] = (85, 220, 0.9), (115, 220, 0.9)
    ang = math.radians(metrics["arm_angle_deg"])
    gap = metrics["wrist_gap_min"] * 100
    for sho, elb, wri, sign in ((2, 3, 4, -1), (5, 6, 7, 1)):
        kps[elb] = (kps[sho][0] + sign * 50 * math.sin(ang), 65 + 50 * math.cos(ang), 0.9)
        # zapesti presne `gap` od osy (x=100), uhel od ramene sedi na arm_angle
        wx = 100 + sign * gap
        wy = 65 + abs(wx - kps[sho][0]) / math.tan(ang) if ang > 0 else 65 + 100
        kps[wri] = (wx, wy, 0.9)
    if metrics.get("ankles_visible"):
        kps[10], kps[13] = (85, 420, 0.9), (115, 420, 0.9)
    return kps


class TestSavePoseKpsFilename(unittest.TestCase):
    """save_pose_kps() ve zdrojovem uzlu jmenuje soubor jinak nez ostatni
    savery ("{filename}_{counter:05}.json", bez podtrzitka pred priponou) -
    overeno ve zdrojaku, ComfyUI bylo pri implementaci vypnute."""

    def test_json_filename_has_no_trailing_underscore(self):
        wf = {"3": {"class_type": "SavePoseKpsAsJsonFile",
                    "inputs": {"pose_kps": ["2", 1], "filename_prefix": "fc/pose"}}}
        self.assertEqual(fc_worker.prefix_candidates(wf), [("pose_00001.json", "fc", "output")])

    def test_other_savers_keep_the_underscore_pattern(self):
        wf = {"3": {"class_type": "SaveImage", "inputs": {"filename_prefix": "fc/apose"}}}
        self.assertIn(("apose_00001_.png", "fc", "output"), fc_worker.prefix_candidates(wf))
