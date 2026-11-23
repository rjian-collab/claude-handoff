#!/usr/bin/env bash
# zh-tw-helper: PostToolUse hook for Write|Edit.
# Reads the hook JSON from stdin, finds tool_input.file_path, and if the file
# is .md or .txt and contains common Simplified-only characters, prints a
# warning to stderr and exits 2 (Claude sees it). Otherwise exits 0.
# Only needs bash + grep + sed (all included with Git for Windows).

input="$(cat | tr -d '\r\n')"

# Extract "file_path":"..." (first occurrence) and unescape JSON backslashes.
file_path="$(printf '%s' "$input" \
  | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | sed 's/\\\\/\//g')"

[ -z "$file_path" ] && exit 0

case "$file_path" in
  *.md|*.MD|*.Md|*.txt|*.TXT|*.Txt) ;;
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

# Characters that only appear in Simplified Chinese (their Traditional forms differ).
pattern='这|们|软|种|说|时|为|发|过|么|个|来|对|会|让|与|还|进|没|吗|应|该|简|体|实|现|视|频|认|质|息|处|题|网|关|开|门|问|间|经|动|样|学|长'

hits="$(LC_ALL=C grep -n -E "$pattern" "$file_path" 2>/dev/null | head -n 5)"

if [ -n "$hits" ]; then
  {
    echo "[zh-tw-helper] 在 $file_path 中發現疑似「簡體字」。"
    echo "如果這份文件應該是台灣繁體中文，請把簡體字改成繁體，並套用台灣用語（例如 软件→軟體、视频→影片）。"
    echo "如果是刻意保留簡體（例如引用原文），可以忽略這則提醒。"
    echo "前幾個出現的行："
    printf '%s\n' "$hits" | cut -c1-200
  } >&2
  exit 2
fi

exit 0
