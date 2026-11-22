---
name: handoff-load
description: Load a handoff checkpoint (HANDOFF.md) written by another Claude account or chat and continue the work exactly where it stopped. Reads from the local ClaudeHandoff folder or the user's private GitHub repo claude-handoff-data. Use when the user says "接續", "繼承", "接著做", "在手機上接續", "load handoff", "resume", "continue from other account", "continue on phone", or mentions switching accounts after a usage limit.
---

# Handoff Load（接續工作）

The user hit a usage limit in another account/chat (or switched to the phone) and continues here. Continue the work without redoing it.

## Steps

1. **Find the handoff location** (see "Where the handoff lives" below). Nothing found: tell the user, in Traditional Chinese, to click **+ → Add folder** and connect `ClaudeHandoff` (desktop), open the private repo `claude-handoff-data` (phone / Claude Code on the web), or paste the HANDOFF.md content into the chat.
2. **Pick the project.** List the project subfolders, most recently updated first (in a fresh git clone, file times are not reliable: use each HANDOFF.md "Last updated" or `git log -1 -- <slug>`).
   - If the user named a project, match it to a slug (case-insensitive, partial match OK).
   - No exact match: show the 3 closest matches (with last-updated time) and ask which one.
   - No name given: show the list and suggest the most recent one.
3. **Read** `<slug>/HANDOFF.md` and the last ~10 lines of `<slug>/LOG.md`.
4. **Restate** in 3–5 lines (Traditional Chinese): the goal, what is done, the exact point of interruption, and the next step.
5. **Verify before continuing.** Check that the files listed actually exist and are in the stated state (open them, look for the half-written part, run a quick check if cheap). If something differs from the handoff, report the difference briefly and adjust the plan — trust the real files over the handoff.
6. **Apply the memory snapshot** (language, skill level, preferences) for the rest of the conversation.
7. **Continue the "Next steps" directly.** Do not ask "shall I continue?" unless the next step is destructive or genuinely ambiguous.
8. **Start checkpointing immediately** per the handoff-save skill: overwrite HANDOFF.md after each milestone, append to LOG.md, and record this account in "Last updated".

## Where the handoff lives

Check in this order:

1. **A connected local folder named `ClaudeHandoff`** (desktop app: + → "Add folder"; usually `%USERPROFILE%\ClaudeHandoff`). Use whatever file / device tools are available.
   - If it is a git repo (has `.git/`) and you can run shell commands there: `git pull --rebase --autostash` before reading, and after writing `git add -A && git commit -m "handoff: <project> <time>" && git push`.
   - Otherwise just write the files; the user's auto-sync task (every 10 min) uploads them.
2. **Git access to the user's PRIVATE repo `claude-handoff-data`** (e.g. Claude Code on the web / phone with that repo, or a tool that can attach or clone the user's GitHub repos — attach it if such a tool exists). Never create it, and never create it public; if it is missing, tell the user to run `scripts/setup-private-repo.bat` from claude-handoff.
   - `git pull --rebase` before reading; after each write: `git add -A && git commit -m "handoff: <project> <time>" && git push`.
   - On push rejection or conflict: `git pull --rebase`, then for `HANDOFF.md` keep the newest version (yours, if you just wrote it); for `LOG.md` keep both sides' lines; continue the rebase and push again.
3. **Neither**: output the full file content in one code block and tell the user (in Traditional Chinese) where to save it.

**Never** write handoff data or shared skills into the public tool repo `claude-handoff`.

Always pull first (when it is a git repo) so you read the newest checkpoint from the other device or account.

## Fallback: no checkpoint exists

If the user pastes the end of an old chat instead (e.g. "請用 handoff-load 規則整理並接續"), build a HANDOFF.md from the pasted text using the handoff-save template, save it (or show it in a code block), restate it, then continue as above. Mark anything uncertain as `（未確認）`.

## Privacy

Do not copy secrets into new files. If the handoff came from a company (Team) account and this is a personal account (or vice versa), do not move confidential company data across unless the user confirms it is allowed.
