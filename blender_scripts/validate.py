"""Vyhodnoceni report.json -> PASS/WARN/FAIL. Bezi BEZ Blenderu (worker,
golden test v CI). Kriteria dle spec/roblox_spec.json."""
import json
import sys


def verdict(report):
    reasons = []
    if report["tri_count"] > report["max_tris"]:
        reasons.append(("FAIL", f"tri_count {report['tri_count']} > {report['max_tris']}"))
    if not report["uv_ok"]:
        reasons.append(("FAIL", "chybi UV"))
    if report.get("material_count", 1) > 1:
        reasons.append(("WARN", f"{report['material_count']} materialu (Roblox chce 1)"))
    if not report.get("watertight", True):
        reasons.append(("WARN", "mesh neni watertight"))
    over = [d for d, l in zip(report["bbox"], (report["bbox_limit_studs"][0],
            report["bbox_limit_studs"][2], report["bbox_limit_studs"][1])) if d > l * 1.001]
    if over:
        reasons.append(("FAIL", f"bbox presahuje limit: {report['bbox']}"))
    if any(level == "FAIL" for level, _ in reasons):
        return "FAIL", reasons
    if reasons:
        return "WARN", reasons
    return "PASS", []


if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        report = json.load(f)
    v, reasons = verdict(report)
    print(json.dumps({"verdict": v, "reasons": [r for _, r in reasons]}))
    sys.exit(0 if v != "FAIL" else 2)
