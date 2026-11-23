# zh-tw-helper：台灣繁體中文寫作與除錯小幫手

這是一個 **Claude Code 外掛（plugin）**，適合用繁體中文寫作、寫程式、在 Windows 11 上遇到問題需要排除的初學者。

## 裡面有什麼？

| 部分 | 名稱 | 做什麼 |
|------|------|--------|
| 指令 | `/zh-tw-helper:polish` | 幫你**潤稿**：修錯字、簡體轉繁體、改成台灣用語、統一全形標點，最後列出「修改清單」 |
| 指令 | `/zh-tw-helper:explain-error` | 用初學者聽得懂的方式，**一步一步解釋錯誤訊息**，並給 Windows 上的修正步驟 |
| 技能（skill） | `zh-tw-writing` | 台灣繁體中文寫作規範。Claude 在寫中文或校對時會**自動參考**，不用手動叫它 |
| 自動檢查（hook） | 簡體字提醒 | Claude 每次寫入或修改 `.md`、`.txt` 檔後，自動檢查有沒有簡體字；有的話會提醒 Claude 修正 |

> 小知識：「指令」是你主動輸入才會執行；「技能」是 Claude 判斷需要時自己使用；「hook」是每次特定動作後自動執行的小程式。

## 安裝前準備（Windows 11）

1. 已安裝 **Claude Code**（在終端機輸入 `claude` 可以啟動）。
2. 已安裝 **Git for Windows**（內含 Git Bash）：<https://git-scm.com/downloads/win>
   - 簡體字提醒 hook 是一個 bash 小程式，在 Windows 上需要 Git Bash 才能執行。
   - 如果 Git 裝在特別的位置、Claude Code 找不到 Git Bash，請設定環境變數 `CLAUDE_CODE_GIT_BASH_PATH` 指向 `bash.exe`，例如：
     ```powershell
     setx CLAUDE_CODE_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
     ```
     設定後**關掉終端機重開**，再啟動 Claude Code。
   - 不需要安裝 Python 或 jq。

## 安裝步驟

1. 開啟 PowerShell 或 Windows Terminal，輸入 `claude` 啟動 Claude Code。
2. 加入這個外掛市集（只要做一次）：
   ```
   /plugin marketplace add rjian-collab/claude-handoff
   ```
3. 安裝外掛：
   ```
   /plugin install zh-tw-helper@rjian-plugins
   ```
   出現安裝畫面時，選擇安裝範圍（建議選 **User**，所有專案都能用）。
4. 輸入 `/reload-plugins`，或關掉 Claude Code 重新開啟。
5. 輸入 `/zh-tw-helper` 看看有沒有出現指令選單，有的話就裝好了。

> 也可以不在 Claude Code 裡面，直接在 PowerShell 執行：
> `claude plugin marketplace add rjian-collab/claude-handoff`
> `claude plugin install zh-tw-helper@rjian-plugins`

## 怎麼使用

### 潤稿：`/zh-tw-helper:polish`

直接把文字接在指令後面：

```
/zh-tw-helper:polish 这个软件的默认设置很好用,视频质量也不错.
```

會得到：
- 潤稿後全文：「這個軟體的預設設定很好用，影片品質也不錯。」
- 一張修改清單表格（原文 → 修改後 → 原因）

也可以給檔案名稱，Claude 會先讀檔、把結果給你看，不會直接改檔：

```
/zh-tw-helper:polish 期末報告.md
```

### 解釋錯誤：`/zh-tw-helper:explain-error`

把錯誤訊息整段貼在指令後面（可以多加一句你在做什麼）：

```
/zh-tw-helper:explain-error 'python' is not recognized as an internal or external command
```

Claude 會依序說明：一句話解釋 → 拆解錯誤訊息 → 可能原因 → 一步一步修正（含 PowerShell／命令提示字元指令）→ 怎麼確認修好 → 下次怎麼避免。

### 寫作技能：`zh-tw-writing`

不用特別輸入指令。當你請 Claude 用中文寫文件、作業、README，或說「幫我改成台灣用語」時，Claude 會自動套用規範（全形標點「」，。、、台灣用語、中英文之間加空格）。

### 簡體字提醒 hook

自動執行，不用操作。當 Claude 寫入或修改 `.md` 或 `.txt` 檔，而檔案裡有「这、们、软、说、时……」等簡體字時，Claude 會收到提醒並主動修正。如果你是刻意保留簡體字（例如引用原文），跟 Claude 說「保留簡體」即可。

## 怎麼關掉 hook（或整個外掛）

- **暫時停用整個外掛**：在 Claude Code 輸入 `/plugin`，到 **Installed**（已安裝）分頁選 `zh-tw-helper` → **Disable**；或在 PowerShell 執行：
  ```
  claude plugin disable zh-tw-helper@rjian-plugins
  ```
  要恢復就改成 `enable`。
- **只想關掉 hook、保留指令和技能**：外掛的 hook 無法單獨關閉，可以：
  1. 暫時關掉所有 hook：在設定檔 `%USERPROFILE%\.claude\settings.json` 加入 `"disableAllHooks": true`（注意：這會關掉**所有** hook，不只這一個）。
  2. 或自己複製一份外掛，刪掉 `hooks/hooks.json` 後用 `claude --plugin-dir <資料夾路徑>` 載入。
- **完全移除**：`/plugin uninstall zh-tw-helper@rjian-plugins`

## 檔案結構

```
plugins/zh-tw-helper/
├─ .claude-plugin/plugin.json        ← 外掛資訊（名稱、版本）
├─ commands/
│  ├─ polish.md                      ← /zh-tw-helper:polish
│  └─ explain-error.md               ← /zh-tw-helper:explain-error
├─ skills/zh-tw-writing/SKILL.md     ← 台灣繁體中文寫作規範
├─ hooks/hooks.json                  ← 設定：寫檔後執行檢查
├─ scripts/check-simplified.sh       ← 簡體字檢查小程式（bash）
└─ README.md
```

## 常見問題

- **指令沒出現？** 輸入 `/reload-plugins`，或用 `/plugin` 檢查外掛是否為 enabled，也可以看 **Errors** 分頁。
- **hook 出現 `$'\r': command not found`？** 表示 `.sh` 檔被轉成 Windows 換行（CRLF）。本專案的 `.gitattributes` 已設定 `.sh` 固定使用 LF；如果你手動下載 ZIP 修改過，請用 VS Code 右下角把換行改成 **LF** 再存檔。
- **想更新外掛？** `/plugin marketplace update rjian-plugins`，然後重新啟動 Claude Code。
