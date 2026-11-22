#!/usr/bin/env python3
"""Zip every skill folder in the shared skills directory for manual upload (stdlib only).

Default directory: %USERPROFILE%\\ClaudeHandoff\\skills  (or pass a path as the first argument).
Output: <dir>/_zips/<skill-name>.zip, each containing <skill-name>/SKILL.md (+ other files).

Usage:  python scripts/pack-shared-skills.py [shared-skills-dir]
"""
import sys
import zipfile
from pathlib import Path


def main() -> int:
    if len(sys.argv) > 1:
        src = Path(sys.argv[1]).expanduser()
    else:
        src = Path.home() / "ClaudeHandoff" / "skills"
    if not src.is_dir():
        print(f"找不到資料夾 Folder not found: {src}")
        return 1
    out_dir = src / "_zips"
    out_dir.mkdir(exist_ok=True)
    count = 0
    for folder in sorted(p for p in src.iterdir() if p.is_dir() and p.name != "_zips"):
        if not (folder / "SKILL.md").is_file():
            print(f"略過（沒有 SKILL.md）Skipped, no SKILL.md: {folder.name}")
            continue
        out = out_dir / f"{folder.name}.zip"
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
            for path in sorted(p for p in folder.rglob("*") if p.is_file()):
                zf.write(path, path.relative_to(src).as_posix())
        print(f"已打包 Packed: {out}")
        count += 1
    print(f"完成，共 {count} 個技能。Done: {count} skill(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
