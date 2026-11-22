---
name: skill-share
description: Share the user's OWN custom skills between their Claude accounts (e.g. Team and Personal) through the local ClaudeHandoff folder. Export copies a skill into ClaudeHandoff/skills/; import installs it in the other account. Use when the user says "共用技能", "分享技能", "同步技能", "把技能搬到另一個帳號", "匯入共用技能", "export skill", or "import skill".
---

# Skill Share（共用技能）

Skills cannot be installed into another account directly. This skill moves them through the shared folder `ClaudeHandoff/skills/` (find `ClaudeHandoff` the same way as handoff-save: a connected folder named `ClaudeHandoff`; if none, ask the user to click **+ → Add folder** and connect it).

Talk to the user in Traditional Chinese, step by step (they may be a beginner).

## Export（匯出，在原本的帳號）

1. Decide which skills: the ones the user names, or all of the user's own skills if they say "全部 / all".
   - **Only the user's own custom skills.** Do NOT export built-in Anthropic skills (e.g. `anthropic-skills:*`, docx, pdf, xlsx…) or skills that come from plugins. If unsure whether a skill is the user's own, ask.
2. For each skill, copy the **complete folder** (SKILL.md plus any scripts/, references/, templates…) to `ClaudeHandoff/skills/<skill-name>/`.
   - Read the original files from disk if you can see them (skill folders, or the content the Skill tool loads).
   - If you cannot access the original files, write `SKILL.md` from the loaded skill content (keep the YAML frontmatter `name` and `description` exactly), and tell the user which bundled files (scripts, references) may be missing.
   - If the folder already exists, overwrite it (it is an update) and say so.
3. Update `ClaudeHandoff/skills/INDEX.md` (create if missing). One table row per skill, replacing any older row for the same name:

   ```markdown
   # 共用技能清單 Shared skills
   | 名稱 Name | 說明 Description | 匯出日期 Exported | 來源帳號 From |
   |---|---|---|---|
   | game-save | 遊戲進度存檔 | 2026-11-22 | Personal |
   ```
4. **Team / company account**: before exporting, warn that skills may contain company-confidential content (internal procedures, code, customer names). Export only if the user confirms their organization allows it. Never export passwords, API keys or tokens — replace them with `<secret — removed>`.
5. Tell the user the next steps: switch account (lower-left name menu) → new chat → **+ → Add folder** → `ClaudeHandoff` → say「匯入共用技能」.

## Import（匯入，在另一個帳號）

1. List `ClaudeHandoff/skills/` (use INDEX.md if present; ignore `_zips/`). Show name, description, exported date, source account. Ask which to import (or "全部").
2. Check which skills already exist in this account (by `name`). Skip existing ones unless the user wants to update them.
3. For each chosen skill, read its `SKILL.md`:
   - **Preferred:** if a `propose_skills` tool is available, call it — kind `"new"` with the full `skillMd` for new skills; for updates of an existing skill, propose it as an improvement with the edits. Tell the user to click **Save / 儲存** on each review card.
   - **Fallback** (no such tool, or the skill has extra files the tool cannot carry): zip the folder so the zip root is the skill folder (`<skill-name>/SKILL.md`, …) into `ClaudeHandoff/skills/_zips/<skill-name>.zip`, or tell the user to run `scripts/pack-shared-skills.bat` from claude-handoff. Then explain manual upload: lower-left name → Settings → Capabilities / Skills → upload the zip (menu labels may vary).
4. Summarize what was imported, skipped, or needs manual upload.

## Notes

- The shared folder is the user's private data. It must never be put into a public repository.
- The same rules apply in both directions (Team → Personal and Personal → Team).
