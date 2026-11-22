---
name: handoff-load
description: Load a handoff checkpoint (HANDOFF.md) written by another Claude account or chat and continue the work exactly where it stopped. Use when the user says "接續", "繼承", "接著做", "load handoff", "resume", "continue from other account", or mentions switching accounts after a usage limit.
---

# Handoff Load（接續工作）

The user hit a usage limit in another account/chat and switched here. Continue the work without redoing it.

## Steps

1. **Find the handoff folder** (same order as handoff-save):
   1. A connected folder named `ClaudeHandoff` (check with the available file / device tools).
   2. Claude Code: `<repo>/.handoff/`.
   3. Nothing found: tell the user, in Traditional Chinese, to click **+ → Add folder** and connect `ClaudeHandoff`, or to paste the HANDOFF.md content into the chat.
2. **Pick the project.** List the project subfolders, most recently updated first.
   - If the user named a project, match it to a slug (case-insensitive, partial match OK).
   - No exact match: show the 3 closest matches (with last-updated time) and ask which one.
   - No name given: show the list and suggest the most recent one.
3. **Read** `<slug>/HANDOFF.md` and the last ~10 lines of `<slug>/LOG.md`.
4. **Restate** in 3–5 lines (Traditional Chinese): the goal, what is done, the exact point of interruption, and the next step.
5. **Verify before continuing.** Check that the files listed actually exist and are in the stated state (open them, look for the half-written part, run a quick check if cheap). If something differs from the handoff, report the difference briefly and adjust the plan — trust the real files over the handoff.
6. **Apply the memory snapshot** (language, skill level, preferences) for the rest of the conversation.
7. **Continue the "Next steps" directly.** Do not ask "shall I continue?" unless the next step is destructive or genuinely ambiguous.
8. **Start checkpointing immediately** per the handoff-save skill: overwrite HANDOFF.md after each milestone, append to LOG.md, and record this account in "Last updated".

## Fallback: no checkpoint exists

If the user pastes the end of an old chat instead (e.g. "請用 handoff-load 規則整理並接續"), build a HANDOFF.md from the pasted text using the handoff-save template, save it (or show it in a code block), restate it, then continue as above. Mark anything uncertain as `（未確認）`.

## Privacy

Do not copy secrets into new files. If the handoff came from a company (Team) account and this is a personal account (or vice versa), do not move confidential company data across unless the user confirms it is allowed.
