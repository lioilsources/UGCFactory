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


if __name__ == "__main__":
    unittest.main()
