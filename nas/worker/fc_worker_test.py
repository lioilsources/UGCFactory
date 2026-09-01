"""Testy casti FC workeru, ktere nepotrebuji Blender ani ComfyUI:

    python3 -m unittest discover -s worker -p 'fc_*_test.py'

Blenderove a ComfyUI kroky se takhle otestovat nedaji - ty overuje az
golden test v kontejneru, resp. beh proti Sparku.
"""
import json
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
