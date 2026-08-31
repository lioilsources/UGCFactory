"""Frame ranges -> Lua tabulka pro Luanti. Bezi BEZ Blenderu, stejne jako
validate.py, aby to slo otestovat v CI bez bpy.

Luanti prepina klipy jen cislem snimku (set_animation({x=,y=})), takze tohle
je jediny most mezi pojmenovanymi klipy v glTF a mobem ve hre.
"""


def normalize(ranges):
    """Zahodi rozsahy, ktere nedavaji smysl - radsi klip vynechat nez dat
    Luanti prazdny interval, na kterem mob zamrzne na jednom snimku."""
    out = {}
    for clip, value in (ranges or {}).items():
        if not isinstance(value, (list, tuple)) or len(value) != 2:
            continue
        start, end = int(value[0]), int(value[1])
        if end <= start:
            continue
        out[clip] = (start, end)
    return out


def lua_table(slug, ranges):
    lines = [
        "-- generovano fc_luanti_pack.py, needituj rucne",
        f'-- klipy pro fantasy_mobs:{slug}; pouziti: set_animation(ranges.idle_01)',
        "return {",
    ]
    for clip, (start, end) in sorted(normalize(ranges).items()):
        lines.append(f'\t["{clip}"] = {{x = {start}, y = {end}}},')
    lines.append("}")
    return "\n".join(lines) + "\n"


def write_ranges_lua(path, slug, ranges):
    with open(path, "w") as f:
        f.write(lua_table(slug, ranges))
