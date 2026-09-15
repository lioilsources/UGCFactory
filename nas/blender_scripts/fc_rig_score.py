"""Jak moc se mesh pri animaci trha: skore rigu pro automatickou volbu.

    blender -b -P fc_rig_score.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "blend": animated.blend z fc_retarget.py, "frame_step": 2}

Pro kazdou hranu se v kazdem snimku spocita r = delka / klidova delka a bere
se max(r, 1/r) - natazeni i smrsteni jsou stejne spatne. stretch_mean je
prumer pres hrany a snimky, 1.0 = zadna deformace.

Proc prave tohle cislo: na peti postavach (plan §13) vybralo pokazde ten rig,
ktery i na renderu vypadal lip - MIA u fotek cele postavy (1.20 proti 1.33),
sablonu u rytire s plastem (1.23 proti 1.59) a u orezanych postav. Nejhorsi
hrany (stretch_p999) se hlasi, ale nerozhoduji: u MIA je dela blana mezi
rukou a bokem, ktera na celkovem dojmu tolik nezmeni.
"""
import argparse
import json
import sys

import bpy
import numpy as np


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def coords(obj, mesh):
    n = len(mesh.vertices)
    co = np.empty(n * 3, dtype=np.float64)
    mesh.vertices.foreach_get("co", co)
    m = np.array(obj.matrix_world)
    return co.reshape(n, 3) @ m[:3, :3].T + m[:3, 3]


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    bpy.ops.wm.open_mainfile(filepath=job["blend"])
    scene = bpy.context.scene
    objs = [o for o in scene.objects
            if o.type == "MESH" and any(m.type == "ARMATURE" for m in o.modifiers)]
    if not objs:
        raise RuntimeError("v blendu neni skinovany mesh")

    edges, rest_len, rest_min_z = {}, {}, None
    for o in objs:
        e = np.empty(len(o.data.edges) * 2, dtype=np.int64)
        o.data.edges.foreach_get("vertices", e)
        edges[o.name] = e.reshape(-1, 2)
        rest = coords(o, o.data)
        rest_len[o.name] = np.linalg.norm(rest[edges[o.name][:, 0]] - rest[edges[o.name][:, 1]], axis=1)
        z = float(rest[:, 2].min())
        rest_min_z = z if rest_min_z is None else min(rest_min_z, z)

    total, count, worst, lowest = 0.0, 0, [], None
    step = max(int(job.get("frame_step", 2)), 1)
    frames = range(scene.frame_start, scene.frame_end + 1, step)
    for frame in frames:
        scene.frame_set(frame)
        dg = bpy.context.evaluated_depsgraph_get()
        for o in objs:
            ev = o.evaluated_get(dg)
            me = ev.to_mesh()
            if len(me.vertices) != len(o.data.vertices):
                ev.to_mesh_clear()
                raise RuntimeError(f"{o.name}: animovany mesh ma jinou topologii")
            posed = coords(ev, me)
            ev.to_mesh_clear()
            e = edges[o.name]
            length = np.linalg.norm(posed[e[:, 0]] - posed[e[:, 1]], axis=1)
            ok = rest_len[o.name] > 1e-5
            r = length[ok] / rest_len[o.name][ok]
            s = np.maximum(r, 1.0 / np.maximum(r, 1e-6))
            total += float(s.sum())
            count += int(ok.sum())
            worst.append(float(np.percentile(s, 99.9)) if len(s) else 1.0)
            z = float(posed[:, 2].min())
            lowest = z if lowest is None else min(lowest, z)

    report = {
        "stretch_mean": round(total / max(count, 1), 4),
        "stretch_p999": round(max(worst), 3) if worst else None,
        "feet_lowest_m": round(lowest - rest_min_z, 3) if lowest is not None else None,
        "frames": len(frames),
    }
    print("FC_SCORE_OK", json.dumps(report), flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_SCORE_FAIL {e}", file=sys.stderr)
        sys.exit(1)
