---
name: skill-share
description: Share the user's OWN custom skills between their Claude accounts (e.g. Team and Personal) through the local ClaudeHandoff folder or the user's private GitHub repo claude-handoff-data. Export copies a skill into the shared skills/ folder; import installs it in the other account. Use when the user says "共用技能", "分享技能", "同步技能", "把技能搬到另一個帳號", "匯入共用技能", "在手機上匯入技能", "export skill", or "import skill".
---

# Skill Share（共用技能）

Skills cannot be installed into another account directly. This skill moves them through the shared folder `skills/` inside the handoff location.

## Where the shared folder lives

Use `<location>/skills/`, checking locations in this order:

1. **A connected local folder named `ClaudeHandoff`** (desktop app: + → "Add folder"; usually `%USERPROFILE%\ClaudeHandoff`). Use whatever file / device tools are available.
   - If it is a git repo (has `.git/`) and you can run shell commands there: `git pull --rebase --autostash` before reading, and after writing `git add -A && git commit -m "skills: <skill-name> <time>" && git push`.
   - Otherwise just write the files; the user's auto-sync task (every 10 min) uploads them.
2. **Git access to the user's PRIVATE repo `claude-handoff-data`** (e.g. Claude Code on the web / phone with that repo, or a tool that can attach or clone the user's GitHub repos — attach it if such a tool exists). Never create it, and never create it public; if it is missing, tell the user to run `scripts/setup-private-repo.bat` from claude-handoff.
   - `git pull --rebase` before reading; after each write: `git add -A && git commit -m "skills: <skill-name> <time>" && git push`.
   - On push rejection or conflict: `git pull --rebase`, then for `HANDOFF.md` keep the newest version (yours, if you just wrote it); for `LOG.md` keep both sides' lines; continue the rebase and push again.
3. **Neither**: output the full file content in one code block and tell the user (in Traditional Chinese) where to save it.

**Never** write handoff data or shared skills into the public tool repo `claude-handoff`.

Talk to the user in Traditional Chinese, step by step (they may be a beginner).

## Export（匯出，在原本的帳號）

1. Decide which skills: the ones the user names, or all of the user's own skills if they say "全部 / all".
   - **Only the user's own custom skills.** Do NOT export built-in Anthropic skills (e.g. `anthropic-skills:*`, docx, pdf, xlsx…) or skills that come from plugins. If unsure whether a skill is the user's own, ask.
2. For each skill, copy the **complete folder** (SKILL.md plus any scripts/, references/, templates…) to `<location>/skills/<skill-name>/`.
   - Read the original files from disk if you can see them (skill folders, or the content the Skill tool loads).
   - If you cannot access the original files, write `SKILL.md` from the loaded skill content (keep the YAML frontmatter `name` and `description` exactly), and tell the user which bundled files (scripts, references) may be missing.
   - If the folder already exists, overwrite it (it is an update) and say so.
3. Update `<location>/skills/INDEX.md` (create if missing). One table row per skill, replacing any older row for the same name:

   ```markdown
   # 共用技能清單 Shared skills
   | 名稱 Name | 說明 Description | 匯出日期 Exported | 來源帳號 From |
   |---|---|---|---|
   | game-save | 遊戲進度存檔 | 2026-11-22 | Personal |
   ```
4. **Team / company account**: before exporting, warn that skills may contain company-confidential content (internal procedures, code, customer names). Export only if the user confirms their organization allows it. Never export passwords, API keys or tokens — replace them with `<secret — removed>`.
5. If the location is a git repo, commit and push (see above). Tell the user the next steps: switch account (lower-left name menu) → new chat → **+ → Add folder** → `ClaudeHandoff` (or open `claude-handoff-data` on the phone) → say「匯入共用技能」.

## Import（匯入，在另一個帳號）

1. Pull first if it is a git repo, then list `<location>/skills/` (use INDEX.md if present; ignore `_zips/`). Show name, description, exported date, source account. Ask which to import (or "全部").
2. Check which skills already exist in this account (by `name`). Skip existing ones unless the user wants to update them.
3. For each chosen skill, read its `SKILL.md`:
   - **Preferred:** if a `propose_skills` tool is available, call it — kind `"new"` with the full `skillMd` for new skills; for updates of an existing skill, propose it as an improvement with the edits. Tell the user to click **Save / 儲存** on each review card.
   - **Fallback** (no such tool, or the skill has extra files the tool cannot carry): zip the folder so the zip root is the skill folder (`<skill-name>/SKILL.md`, …) into `<location>/skills/_zips/<skill-name>.zip`, or tell the user to run `scripts/pack-shared-skills.bat` from claude-handoff. Then explain manual upload: lower-left name → Settings → Capabilities / Skills → upload the zip (menu labels may vary).
4. Summarize what was imported, skipped, or needs manual upload.

## Notes

- The shared folder is the user's private data. It must never be put into a public repository.
- The same rules apply in both directions (Team → Personal and Personal → Team).
