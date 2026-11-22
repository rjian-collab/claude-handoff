#!/usr/bin/env python3
"""Zip each folder in skills/ into dist/<skill-name>.zip (standard library only).

Each zip contains <skill-name>/SKILL.md (plus any other files in the folder),
which is the layout the claude.ai Skills upload accepts.

Usage:  python scripts/build-skills.py
"""
import re
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
DIST = ROOT / "dist"
FIXED_TIME = (2026, 1, 1, 0, 0, 0)  # fixed timestamp -> reproducible zips


def check_frontmatter(skill_md: Path, folder_name: str) -> None:
    text = skill_md.read_text(encoding="utf-8")
    m = re.match(r"^---\r?\n(.*?)\r?\n---\r?\n", text, re.S)
    if not m:
        sys.exit(f"ERROR: {skill_md} has no YAML frontmatter")
    fields = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            fields[key.strip()] = value.strip()
    if fields.get("name") != folder_name:
        sys.exit(f"ERROR: {skill_md}: name must be '{folder_name}'")
    desc = fields.get("description", "")
    if not desc or len(desc) > 1024:
        sys.exit(f"ERROR: {skill_md}: description missing or over 1024 chars")


def build(folder: Path) -> Path:
    check_frontmatter(folder / "SKILL.md", folder.name)
    out = DIST / f"{folder.name}.zip"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(p for p in folder.rglob("*") if p.is_file()):
            arcname = path.relative_to(SKILLS).as_posix()
            info = zipfile.ZipInfo(arcname, FIXED_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            zf.writestr(info, path.read_bytes())
    return out


def main() -> None:
    DIST.mkdir(exist_ok=True)
    folders = sorted(p for p in SKILLS.iterdir() if (p / "SKILL.md").is_file())
    if not folders:
        sys.exit("ERROR: no skills found")
    for folder in folders:
        out = build(folder)
        print(f"built {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
