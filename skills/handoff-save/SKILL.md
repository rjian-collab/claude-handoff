---
name: handoff-save
description: Save a handoff checkpoint (HANDOFF.md) so work can continue in another Claude account, chat, or on the phone after a usage limit cuts the session off. Writes to the local ClaudeHandoff folder or the user's private GitHub repo claude-handoff-data. Use when the user says "save handoff", "checkpoint", "存檔", "交接", "用量快用完", "準備換帳號", and also PROACTIVELY, without being asked, after every meaningful milestone and whenever the conversation is getting long.
---

# Handoff Save（交接存檔）

The checkpoint lets work continue in the other account, a new chat, or on the phone. Usage limits cut a session off **without warning**. The last checkpoint is all that survives. So checkpoint **automatically** — never wait to be asked.

## When to save

- After each meaningful milestone (a file written, a bug fixed, a decision made, a step of the plan finished).
- When the conversation is long (roughly every 10–15 exchanges, or after any large output).
- Immediately when the user says: save handoff / checkpoint / 存檔 / 交接 / 用量快用完 / 要換帳號.
- Before starting a long or risky step.

Keep it quick: one short line to the user is enough (e.g. `（已存檔交接 HANDOFF.md）`). Do not interrupt the work to ask permission.

## Where to save

Find the handoff location in this order:

1. **A connected local folder named `ClaudeHandoff`** (desktop app: + → "Add folder"; usually `%USERPROFILE%\ClaudeHandoff`). Use whatever file / device tools are available.
   - If it is a git repo (has `.git/`) and you can run shell commands there: `git pull --rebase --autostash` before reading, and after writing `git add -A && git commit -m "handoff: <project> <time>" && git push`.
   - Otherwise just write the files; the user's auto-sync task (every 10 min) uploads them.
2. **Git access to the user's PRIVATE repo `claude-handoff-data`** (e.g. Claude Code on the web / phone with that repo, or a tool that can attach or clone the user's GitHub repos — attach it if such a tool exists). Never create it, and never create it public; if it is missing, tell the user to run `scripts/setup-private-repo.bat` from claude-handoff.
   - `git pull --rebase` before reading; after each write: `git add -A && git commit -m "handoff: <project> <time>" && git push`.
   - On push rejection or conflict: `git pull --rebase`, then for `HANDOFF.md` keep the newest version (yours, if you just wrote it); for `LOG.md` keep both sides' lines; continue the rebase and push again.
3. **Neither** (e.g. web chat without file access): output the full HANDOFF.md in one code block and tell the user (in Traditional Chinese) to save it as `ClaudeHandoff\<project-slug>\HANDOFF.md`.

In **Claude Code inside a normal project repo** (not `claude-handoff-data`) you may instead use `<repo>/.handoff/` (see the CLAUDE.md snippet); remind the user to gitignore it if the repo is public.

**Never** write handoff data or shared skills into the public tool repo `claude-handoff`.

If no location can be found, say so once and use option 3 — do not silently skip the checkpoint.

## What to write

Inside the folder, use one subfolder per project: `<project-slug>/` (lowercase, hyphens, e.g. `game-dev`, `thesis-report`). Reuse the existing slug if the project already has one.

1. **`<project-slug>/HANDOFF.md`** — the *current state*. **Overwrite** it each time. Follow the template below. Keep it under ~150 lines; summarize older detail instead of piling it up.
2. **`<project-slug>/LOG.md`** — **append** one line per checkpoint, never rewrite:
   `- 2026-11-22 14:30 [Personal] Finished login page; next: connect database`

### Rules for good content

- **In progress** must name the *exact* point of interruption: file, function, step number, the command just run and its result.
- **Next steps** must be numbered and concrete enough that a fresh Claude with no memory can start immediately.
- **Files**: real paths, and the state of each (done / half-written / untested).
- **Memory snapshot**: durable facts and preferences relevant to this project that the other account's memory will NOT have (e.g. "user is a beginner, explain step by step", "reply in Traditional Chinese", "uses Windows 11", tool versions, naming choices). Only what helps continue the work.
- **Last updated**: date/time and which account (Team / Personal) if known; otherwise "unknown".
- Write in Traditional Chinese by default (keep code, paths and commands as-is).

## Privacy

- **Never** include passwords, API keys, tokens, cookies, or other secrets. Write `<secret — stored elsewhere>` instead.
- On a **Team / company account**, do not include confidential company data (internal code, customer data, unreleased plans) unless the user confirms their organization allows it. When unsure, ask once and describe it generically.

## Template

```markdown
# 交接檔 HANDOFF — <專案名稱 Project name>

## 專案 Project
- 名稱 Name:
- 代號 Slug:
- 簡介 Summary（一句話）:

## 目標 Goal

## 目前狀態 Status
（一到三句：整體做到哪裡）

## 已完成 Done
-

## 進行中（被中斷時正在做的事）In progress — exact point
- 正在做:
- 精確位置（檔案/函式/步驟）:
- 最後執行的指令與結果:

## 下一步 Next steps
1.
2.
3.

## 關鍵決定與原因 Decisions
- 決定: … — 原因: …

## 檔案與位置 Files
| 路徑 Path | 狀態 State | 說明 Note |
|---|---|---|

## 記憶快照 Memory snapshot
（另一個帳號的記憶裡沒有、但接續工作需要知道的使用者偏好與事實）
-

## 待解問題 Open questions
-

## 最後更新 Last updated
- 時間 Time: YYYY-MM-DD HH:MM
- 帳號 Account: Team / Personal / unknown
```
