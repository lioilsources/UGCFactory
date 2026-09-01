"""Uklizene GLB -> rigovane FBX s Mixamo kostrou, bez neuronky.

    blender -b -P fc_rig_template.py -- --job /data/jobs/<id>.json

Job JSON: {"id", "glb": clean.glb, "out_dir"}

Proc sablona misto auto-rigu: ani UniRig, ani MIA na GB10 nerozbehneme.
UniRig stoji na `cumm`, ktery nezna CUDA arch 12.1 (nezna ji ani nejnovejsi
verze, konci na 12.0). MIA potrebuje `bpy`, ktery pro linux aarch64 nema
wheel, a vola Blender uz pri importu. Mereno 2026-08-31, viz sekce 12 planu.

Tenhle skript proto kostru neodhaduje siti, ale staví ji z proporci meshe a
vahy necha spocitat Blenderu (ARMATURE_AUTO, heat map). Kosti maji Mixamo
jmena, takze `fc_retarget.py` na vysledek sedne beze zmeny a klipy z knihovny
se na nej nasadi stejne jako na rig z neuronky.

Omezeni, ktere je poctive rict dopredu: sablona predpoklada humanoida stojiciho
zpredma. U ctyrnozcu, kridel a ocasu vyjde nesmysl - proto ma report pole
`fit_warnings`, at to pipeline poznaji driv nez uzivatel.
"""
import argparse
import json
import math
import os
import sys

import bpy
from mathutils import Vector

MIXAMO = "mixamorig:"

# Vyskove pomery kostry vuci vysce postavy. Cisla jsou z Mixamo mannequina
# (zmereno na 1.8 m figure), ne vycucana: hips 0.53 je presne to, co dela
# rozdil mezi "stoji" a "sedi v pulce stehen".
RATIOS = {
    "hips": 0.530,
    "spine": 0.585,
    "spine1": 0.640,
    "spine2": 0.700,
    "neck": 0.800,
    "head": 0.855,
    "headtop": 0.975,
    "shoulder": 0.790,
    "knee": 0.270,
    "ankle": 0.045,
    "toe": 0.015,
}


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--job", required=True)
    return ap.parse_args(argv)


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_glb(path):
    bpy.ops.import_scene.gltf(filepath=path)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("GLB obsahuje 0 meshu")
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = "Character"
    return obj


def world_verts(obj):
    m = obj.matrix_world
    return [m @ v.co for v in obj.data.vertices]


def slice_extent(verts, z, band):
    """Sirka a hloubka meshe v pasu kolem vysky z. Kdyz v pasu nic neni,
    vraci None - volajici si pak pomuze bboxem."""
    xs = [v.x for v in verts if abs(v.z - z) <= band]
    ys = [v.y for v in verts if abs(v.z - z) <= band]
    if len(xs) < 3:
        return None
    return (min(xs), max(xs), min(ys), max(ys))


def leg_split(verts, z, band, x_center):
    """Najde stred leve a prave nohy v dane vysce. Mezera mezi nohama se hleda
    jako nejsirsi prazdne misto kolem osy - u postavy s nohama u sebe zadna
    neni a fallback je ctvrtina sirky."""
    xs = sorted(v.x for v in verts if abs(v.z - z) <= band)
    if len(xs) < 6:
        return None
    left = [x for x in xs if x > x_center]
    right = [x for x in xs if x < x_center]
    if not left or not right:
        return None
    return (sum(right) / len(right), sum(left) / len(left))


def arm_axis(verts, cx, cy, z0, height, shoulder_x, sign):
    """Smer, kterym z ramene vede paze, odvozeny z meshe.

    Puvodne sablona vedla paze vodorovne do stran, tedy predpokladala T-pozu.
    Rytir z pipeline ma ale ruce svesene podel tela: mesh je nejsirsi v urovni
    boku (0.78 m) a v ramenou jen 0.57 m. Kosti pak vedly prazdnym prostorem
    vedle hlavy, obalka na ne navazala plast a kus trupu a pri animaci z toho
    byla placka (videno 2026-09-01).

    Bere vrcholy, ktere lezi bocne za linii ramen, a vraci smer k jejich
    tezisti. Plast visi vzadu, takze se vrcholy filtruji i podle hloubky.
    Kdyz jich je malo (skutecna T-poza), vraci None a zustane vodorovna paze.
    """
    zlo, zhi = z0 + height * 0.25, z0 + height * 0.86
    ys = [v.y for v in verts]
    depth = max(ys) - min(ys)
    pts = [v for v in verts
           if zlo <= v.z <= zhi
           and sign * (v.x - cx) > shoulder_x * 0.75
           and abs(v.y - cy) <= depth * 0.35]
    if len(pts) < 20:
        return None, 0
    n = len(pts)
    centroid = Vector((sum(v.x for v in pts) / n,
                       sum(v.y for v in pts) / n,
                       sum(v.z for v in pts) / n))
    return centroid, n


def measure(obj):
    """Z meshe vytahne rozmery, ze kterych se staví kostra."""
    verts = world_verts(obj)
    zs = [v.z for v in verts]
    xs = [v.x for v in verts]
    ys = [v.y for v in verts]
    z0, z1 = min(zs), max(zs)
    height = z1 - z0
    if height <= 0:
        raise RuntimeError("degenerovany mesh (nulova vyska)")
    band = height * 0.02
    x_center = (min(xs) + max(xs)) / 2
    y_center = (min(ys) + max(ys)) / 2

    warnings = []
    m = {"height": height, "z0": z0, "x_center": x_center, "y_center": y_center}

    sh = slice_extent(verts, z0 + height * RATIOS["shoulder"], band * 2)
    if sh is None:
        warnings.append("v urovni ramen neni mesh; sirka odhadnuta z bboxu")
        half = (max(xs) - min(xs)) / 2
        m["shoulder_x"] = half * 0.45
    else:
        m["shoulder_x"] = (sh[1] - sh[0]) / 2 * 0.82

    hips = slice_extent(verts, z0 + height * RATIOS["hips"], band * 2)
    m["hip_x"] = ((hips[1] - hips[0]) / 2 * 0.45) if hips else m["shoulder_x"] * 0.6

    legs = leg_split(verts, z0 + height * RATIOS["knee"], band * 2, x_center)
    if legs is None:
        warnings.append("nohy se nepodarilo rozeznat; pouzita polovina sirky boku")
        m["leg_x"] = m["hip_x"]
    else:
        m["leg_x"] = (abs(legs[0] - x_center) + abs(legs[1] - x_center)) / 2

    # Ruka: od ramene ven. Sirka v urovni ramen zahrnuje i pripadne ruce podel
    # tela, takze delka paze se odvozuje z vysky, ne ze sirky - je stabilnejsi.
    m["arm_len"] = height * 0.155
    m["forearm_len"] = height * 0.145
    m["hand_len"] = height * 0.045

    for side, sign in (("left", 1.0), ("right", -1.0)):
        centroid, n = arm_axis(verts, x_center, y_center, z0, height,
                               m["shoulder_x"], sign)
        m[f"arm_{side}"] = centroid
        m[f"arm_{side}_pts"] = n
    if m["arm_left"] is None and m["arm_right"] is None:
        warnings.append("paze se z meshe nepodarilo najit; vedeny vodorovne")

    ratio = (max(xs) - min(xs)) / height if height else 0
    if ratio > 1.2:
        warnings.append(f"mesh je sirsi nez vyssi (pomer {ratio:.2f}) - humanoid?")
    m["warnings"] = warnings
    return m


def bone_chain(m):
    """(jmeno, head, tail, rodic) pro celou kostru. Jmena jsou Mixamo, protoze
    na ne sedaji klipy z knihovny i fc_retarget.py."""
    h, z0 = m["height"], m["z0"]
    cx, cy = m["x_center"], m["y_center"]
    sx, lx = m["shoulder_x"], m["leg_x"]

    def z(key):
        return z0 + h * RATIOS[key]

    chain = [
        ("Hips", (cx, cy, z("hips")), (cx, cy, z("spine")), None),
        ("Spine", (cx, cy, z("spine")), (cx, cy, z("spine1")), "Hips"),
        ("Spine1", (cx, cy, z("spine1")), (cx, cy, z("spine2")), "Spine"),
        ("Spine2", (cx, cy, z("spine2")), (cx, cy, z("neck")), "Spine1"),
        ("Neck", (cx, cy, z("neck")), (cx, cy, z("head")), "Spine2"),
        ("Head", (cx, cy, z("head")), (cx, cy, z("headtop")), "Neck"),
    ]
    for side, sign in (("Left", 1.0), ("Right", -1.0)):
        sh_x = cx + sign * sx
        shoulder = Vector((sh_x, cy, z("shoulder")))

        # Smer paze z meshe; bez nej (T-poza nebo malo dat) vodorovne ven.
        centroid = m.get(f"arm_{'left' if sign > 0 else 'right'}")
        if centroid is None:
            direction = Vector((sign, 0.0, 0.0))
        else:
            direction = (centroid - shoulder)
            direction.y = 0.0            # plast vzadu nesmi paze stahovat dozadu
            if direction.length < 1e-4:
                direction = Vector((sign, 0.0, 0.0))
            else:
                direction.normalize()

        a1 = shoulder + direction * m["arm_len"]
        a2 = a1 + direction * m["forearm_len"]
        a3 = a2 + direction * m["hand_len"]
        chain += [
            (f"{side}Shoulder", (cx + sign * sx * 0.25, cy, z("shoulder")),
             tuple(shoulder), "Spine2"),
            (f"{side}Arm", tuple(shoulder), tuple(a1), f"{side}Shoulder"),
            (f"{side}ForeArm", tuple(a1), tuple(a2), f"{side}Arm"),
            (f"{side}Hand", tuple(a2), tuple(a3), f"{side}ForeArm"),
            (f"{side}UpLeg", (cx + sign * lx, cy, z("hips")),
             (cx + sign * lx, cy, z("knee")), "Hips"),
            (f"{side}Leg", (cx + sign * lx, cy, z("knee")),
             (cx + sign * lx, cy, z("ankle")), f"{side}UpLeg"),
            (f"{side}Foot", (cx + sign * lx, cy, z("ankle")),
             (cx + sign * lx, cy - h * 0.06, z("toe")), f"{side}Leg"),
            (f"{side}ToeBase", (cx + sign * lx, cy - h * 0.06, z("toe")),
             (cx + sign * lx, cy - h * 0.10, z("toe")), f"{side}Foot"),
        ]
    return chain


def build_armature(m):
    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm = bpy.context.object
    arm.name = "Armature"
    eb = arm.data.edit_bones
    for b in list(eb):
        eb.remove(b)
    for name, head, tail, parent in bone_chain(m):
        bone = eb.new(MIXAMO + name)
        bone.head, bone.tail = Vector(head), Vector(tail)
        if parent:
            bone.parent = eb[MIXAMO + parent]
        bone.use_connect = False
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm


def weighted_verts(mesh):
    return sum(1 for v in mesh.data.vertices
               if any(g.weight > 0.0001 for g in v.groups))


def _parent(mesh, arm, kind):
    bpy.ops.object.select_all(action="DESELECT")
    mesh.select_set(True)
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.parent_set(type=kind)


def open_edges_of(obj):
    """Pocet hran jen s jednou stenou, tedy okraju der."""
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    n = sum(1 for e in bm.edges if len(e.link_faces) < 2)
    bm.free()
    return n


def repair_for_binding(mesh):
    """Heat weighting potrebuje uzavrenou plochu; na meshi s derami selze.
    Cleanup uz jednou remeshoval, presto z nej vysel model se 129 otevrenymi
    hranami (Test Knight, 2026-09-01) - proto se diry zavrou jeste tady,
    tesne pred vazbou. Vraci pocet otevrenych hran pred a po."""
    before = open_edges_of(mesh)
    if before == 0:
        return before, before
    bpy.context.view_layer.objects.active = mesh
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.0005)
    bpy.ops.mesh.select_all(action="DESELECT")
    # jen okraje der, ne dráty a nespojite vrcholy - ty fill_holes nezajimaji
    bpy.ops.mesh.select_non_manifold(
        extend=False, use_wire=False, use_boundary=True,
        use_multi_face=False, use_non_contiguous=False, use_verts=False)
    bpy.ops.mesh.fill_holes(sides=0)          # sides=0 = bez limitu velikosti diry
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    return before, open_edges_of(mesh)


def size_envelopes(arm, height):
    """Obalka bez nastavenych polomeru je k nicemu: Blender ma vychozi
    envelope_distance 0.25 bez ohledu na meritko, takze u 1.8 m postavy
    vetsina vrcholu spadne mimo vsechny kosti nebo do spatne. Polomery se
    proto odvodi z vysky postavy."""
    r = height * 0.055
    bpy.context.view_layer.objects.active = arm
    for b in arm.data.bones:
        b.envelope_distance = max(r, b.length * 0.5)
        b.head_radius = r
        b.tail_radius = r


def bind(mesh, arm):
    """Heat map vahy, s obalkou jako zachranou.

    Heat weighting umi selhat TISE: vytvori vertex groups i modifikator, ale
    nechá je prazdne - stane se to u meshe slozeneho z odpojenych kusu.
    Vyjimka pritom nepadne, takze se to musi poznat spocitanim vah. Zmereno
    na testovaci figure z devíti kvadru: 22 skupin, 0 vah, zadna chyba."""
    _parent(mesh, arm, "ARMATURE_AUTO")
    if weighted_verts(mesh) > 0:
        return "heat"
    print("heat map nechala vahy prazdne, zkousim obalku", flush=True)
    size_envelopes(arm, arm.dimensions.z or 1.8)
    for vg in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(vg)
    for md in [m for m in mesh.modifiers if m.type == "ARMATURE"]:
        mesh.modifiers.remove(md)
    mesh.parent = None
    _parent(mesh, arm, "ARMATURE_ENVELOPE")
    return "envelope" if weighted_verts(mesh) > 0 else "none"


def weld_orphans(mesh, arm):
    """Prirad kazdy vrchol bez vahy nejblizsi kosti.

    Nezavazany vrchol se pri animaci nehne z mista. Kdyz ma klip root motion
    (Mixamo bez volby "In Place"), zbytek postavy odejde pryc a mesh se mezi
    stojicimi a odchazejicimi vrcholy natahne pres celou scenu. Zmereno na
    Test Knight: 203 vrcholu z 3146 zustalo stat a bbox meshe vyrostl behem
    32 snimku z 1.2 na 102 jednotek - presne ty "placky", co bylo videt v
    appce misto postavy.
    """
    bones = [b for b in arm.data.bones]
    if not bones:
        return 0
    groups = {b.name: (mesh.vertex_groups.get(b.name) or mesh.vertex_groups.new(name=b.name))
              for b in bones}
    inv = mesh.matrix_world.inverted()
    heads = [(b.name, inv @ (arm.matrix_world @ b.head_local),
              inv @ (arm.matrix_world @ b.tail_local)) for b in bones]

    fixed = 0
    for v in mesh.data.vertices:
        if any(g.weight > 0.0001 for g in v.groups):
            continue
        best, bestd = None, None
        for name, head, tail in heads:
            mid = (head + tail) / 2
            d = (v.co - mid).length
            if bestd is None or d < bestd:
                best, bestd = name, d
        groups[best].add([v.index], 1.0, "REPLACE")
        fixed += 1
    return fixed


def bone_fit(mesh, arm, names):
    """Prumerna vzdalenost bodu podel kosti k nejblizsimu vrcholu meshe.

    Kdyz kost vede uvnitr koncetiny, je male; kdyz prazdnym prostorem vedle
    tela, je velke. Presne tim se pozna spatne odhadnuta poza driv, nez to
    uvidi uzivatel na animaci.
    """
    verts = [mesh.matrix_world @ v.co for v in mesh.data.vertices]
    if not verts:
        return None
    total, count = 0.0, 0
    for name in names:
        b = arm.data.bones.get(name)
        if b is None:
            continue
        head = arm.matrix_world @ b.head_local
        tail = arm.matrix_world @ b.tail_local
        for i in range(1, 5):
            pt = head.lerp(tail, i / 5.0)
            total += min((pt - v).length for v in verts)
            count += 1
    return round(total / count, 4) if count else None


def max_influences(mesh):
    worst = 0
    for v in mesh.data.vertices:
        worst = max(worst, sum(1 for g in v.groups if g.weight > 0.0001))
    return worst


def unweighted_verts(mesh):
    """Vrcholy bez jedine vahy zustanou pri animaci stat na miste - je to
    nejviditelnejsi projev spatne sedici sablony, tak se pocitaji."""
    return len(mesh.data.vertices) - weighted_verts(mesh)


def export_fbx(path):
    bpy.ops.export_scene.fbx(
        filepath=path,
        use_selection=False,
        add_leaf_bones=False,
        bake_anim=False,
        path_mode="COPY",
        embed_textures=False,
    )


def main():
    args = parse_args()
    with open(args.job) as f:
        job = json.load(f)
    out_dir = job["out_dir"]
    os.makedirs(out_dir, exist_ok=True)

    reset_scene()
    mesh = import_glb(job["glb"])
    m = measure(mesh)
    arm = build_armature(m)
    holes_before, holes_after = repair_for_binding(mesh)
    method = bind(mesh, arm)

    orphans_fixed = weld_orphans(mesh, arm)
    unweighted = unweighted_verts(mesh)
    if method == "none":
        raise RuntimeError("ani heat map, ani obalka nepridelily vahy - "
                           "mesh na humanoidni sablonu nesedi")
    fbx = os.path.join(out_dir, "rigged.fbx")
    export_fbx(fbx)

    report = {
        "fbx": os.path.basename(fbx),
        "bones": len(arm.data.bones),
        "weights": method,
        "open_edges_before_bind": holes_before,
        "open_edges_after_repair": holes_after,
        "max_influences": max_influences(mesh),
        "unweighted_verts": unweighted,
        "orphans_welded": orphans_fixed,
        "vert_count": len(mesh.data.vertices),
        "height_m": round(m["height"], 4),
        "shoulder_half_width": round(m["shoulder_x"], 4),
        "leg_half_width": round(m["leg_x"], 4),
        "arm_fit": bone_fit(mesh, arm, [MIXAMO + n for n in
                            ("LeftArm", "LeftForeArm", "RightArm", "RightForeArm")]),
        "arm_pts": [m.get("arm_left_pts", 0), m.get("arm_right_pts", 0)],
        "fit_warnings": m["warnings"],
    }
    with open(os.path.join(out_dir, "rig_report.json"), "w") as f:
        json.dump(report, f, indent=2)
    print("FC_RIG_OK", json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"FC_RIG_FAIL {e}", file=sys.stderr)
        sys.exit(1)
