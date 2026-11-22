# claude-handoff

**在兩個 Claude 帳號之間接續同一份工作。**
例如：Team 帳號用量用完了，換到個人帳號，不用從頭再來。

> English summary at the bottom.

---

## 它做什麼？

Claude 的不同帳號之間**沒有**共用記憶，也**沒有**辦法讀另一個帳號的對話。
所以這個工具用最簡單的方法：

1. 工作時，Claude 會**自動**把目前進度寫成一份「交接檔」`HANDOFF.md`，存在你電腦上的 `ClaudeHandoff` 資料夾。
2. 換帳號後，新的 Claude 讀這份交接檔，就知道做到哪裡、下一步是什麼，直接接著做。

兩個帳號都能透過 Claude 桌面版的「Add folder」讀寫同一個資料夾，這就是兩邊的「交接區」。

### 誠實說明限制

- **不是自動同步。** 它靠的是「存檔點」（checkpoint）。Claude 會在每完成一個段落、或對話變長時自動存檔，但用量限制會**毫無預警**地中斷對話，所以**能接續的只有最後一次存檔的內容**。
- **如果還沒存過檔就被中斷**：到舊帳號的對話，複製最後一段內容（越完整越好），貼到新帳號的對話，再加一句：
  `請用 handoff-load 規則整理並接續`
- 要在**每個帳號**都安裝一次技能（下面有步驟）。
- 交接檔是給 Claude 看的摘要，不是完整對話紀錄。

---

## 你會拿到什麼

```
claude-handoff/
├─ dist/
│  ├─ handoff-save.zip      ← 存檔技能（上傳到 Claude）
│  ├─ handoff-load.zip      ← 接續技能（上傳到 Claude）
│  └─ skill-share.zip       ← 共用技能（把自己做的技能搬到另一個帳號）
├─ scripts/
│  ├─ setup-windows.bat     ← 雙擊執行，建立 ClaudeHandoff 資料夾
│  ├─ setup-windows.ps1     ← 同上（PowerShell 版）
│  ├─ pack-shared-skills.bat← 把共用技能打包成 zip（手動上傳用）
│  ├─ pack-shared-skills.py ← 同上（Python 程式本體）
│  └─ build-skills.py       ← 開發者用：重新打包 zip
├─ skills/                  ← 技能原始檔
├─ templates/HANDOFF.md     ← 交接檔範本
└─ claude-code/CLAUDE.md.snippet  ← Claude Code 使用者用
```

---

## 安裝（只要做一次）

### 步驟 0：下載這個專案

在 GitHub 頁面按綠色的 **Code** 按鈕 → **Download ZIP**，下載後在檔案上按右鍵 →「解壓縮全部」。

### 步驟 1：建立交接資料夾

1. 打開解壓後的資料夾，進入 `scripts`。
2. 雙擊 **`setup-windows.bat`**。
3. 如果出現藍色的「Windows 已保護您的電腦」：按「其他資訊」→「仍要執行」。
4. 看到「完成！」就好了。它會建立：
   `C:\Users\你的使用者名稱\ClaudeHandoff`
   （裡面有一個 `README.txt` 說明檔，和一個放共用技能的 `skills` 資料夾）

> 這個程式只建立資料夾，不安裝任何東西、不上傳任何資料。
> 想用 PowerShell 版：在 `setup-windows.ps1` 上按右鍵 →「用 PowerShell 執行」。

### 步驟 2：在「每個帳號」上傳三個技能

**Team 帳號做一次，個人帳號也要做一次。**

1. 打開 Claude 桌面版，確認左下角顯示的是你要設定的帳號。
2. 左下角點你的名字 → **Settings（設定）**。
3. 找 **Capabilities（功能）** 或 **Skills（技能）** 相關的頁面。
   （選單名稱可能隨版本不同，找有「Skills」和「上傳 / Upload」字樣的選項。）
4. 上傳 `dist\handoff-save.zip`。
5. 再上傳 `dist\handoff-load.zip`。
6. 再上傳 `dist\skill-share.zip`。
7. 確認三個技能都是**開啟**狀態。
8. 左下角切換到另一個帳號，重複 2～7。

> **Team 帳號注意**：公司/學校的 Team 帳號由管理員控管，管理員可能**關閉了技能上傳**。如果找不到上傳選項，請問管理員。另外請遵守組織的規定：未經允許，不要把公司機密資料存進交接檔（交接檔存在你個人電腦上）。

### 步驟 3：每個新對話都連接資料夾

在 Claude 桌面版開新對話時：

1. 按輸入框旁邊的 **+**。
2. 選 **Add folder**。
3. 選 `C:\Users\你的使用者名稱\ClaudeHandoff`。

這樣 Claude 才能讀寫交接檔。

---

## 使用方式

### 平常工作

1. 開新對話 → 連接 `ClaudeHandoff` 資料夾。
2. 正常請 Claude 幫你做事。
3. Claude 會在完成段落時**自動存檔**，你會看到一句簡短的「已存檔交接」。
4. 想手動存檔也可以，直接說：「**存檔**」或「**交接**」。
5. 覺得用量快用完了，說：「**用量快用完，存檔**」。

### 用量用完了，換帳號

1. 左下角點名字 → 切換到另一個帳號。
2. 開**新對話**。
3. 按 **+** → **Add folder** → 選 `ClaudeHandoff`。
4. 輸入：
   ```
   接續 專案名稱
   ```
   （不記得名稱就只說「接續」，Claude 會列出最近的專案讓你選。）
5. Claude 會先用幾行話說明目前進度，檢查檔案狀態，然後直接接著做。

### 資料夾裡長這樣（含共用技能）

```
ClaudeHandoff\
├─ README.txt
├─ game-dev\
│  ├─ HANDOFF.md   ← 目前進度（每次存檔覆蓋）
│  └─ LOG.md       ← 每次存檔的紀錄（往下加）
├─ thesis-report\
│  ├─ HANDOFF.md
│  └─ LOG.md
└─ skills\          ← 共用技能（見下一節）
   ├─ INDEX.md     ← 共用技能清單
   └─ game-save\
      └─ SKILL.md
```

你可以用記事本打開 `HANDOFF.md` 看 Claude 寫了什麼，也可以自己修改。

---

## 共用技能

你在一個帳號自己做的技能（例如遊戲開發的「存檔 / 接續」技能），另一個帳號預設是沒有的。`skill-share` 技能可以幫你搬過去。

**在原本的帳號（例如個人帳號）匯出：**

1. 開新對話 → **+** → **Add folder** → 選 `ClaudeHandoff`。
2. 輸入：
   ```
   把 技能名稱 技能共用到另一個帳號
   ```
   （要全部搬就說「把我所有自己做的技能共用到另一個帳號」。）
3. Claude 會把技能複製到 `ClaudeHandoff\skills\技能名稱\`，並更新清單 `INDEX.md`。

**在另一個帳號匯入：**

1. 左下角點名字 → 切換帳號。
2. 開新對話 → **+** → **Add folder** → 選 `ClaudeHandoff`。
3. 輸入：
   ```
   匯入共用技能
   ```
4. Claude 會列出可以匯入的技能，選好之後，對話裡會出現技能的確認卡片，按 **儲存（Save）** 就完成了。

**如果沒有出現確認卡片：** 請 Claude 幫你打包成 zip，或自己雙擊 `scripts\pack-shared-skills.bat`（需要安裝 Python；沒有 Python 的話，它會教你用右鍵「壓縮成 ZIP 檔」手動打包）。zip 檔會出現在 `ClaudeHandoff\skills\_zips\`，再到 Settings 的 Skills 頁面上傳即可。

> 只能搬**你自己做的**技能，內建技能不需要也不會搬。
> 從 **Team 帳號**匯出前，Claude 會提醒你：技能裡如果有公司機密內容，要先確認公司允許。

---

## 隱私與安全（很重要）

- **這個工具的 GitHub 專案是公開的，但你的交接資料和共用技能絕對不要放進來。** 它們只存在你電腦上的 `ClaudeHandoff` 資料夾。
- 本專案的 `.gitignore` 已經擋掉 `ClaudeHandoff/`、`.handoff/`、`HANDOFF.md`、`LOG.md`，避免不小心上傳，但請不要依賴它，**不要把資料夾放進這個專案裡**。
- 技能會要求 Claude **不寫入**密碼、API 金鑰、token。你自己也不要在對話中貼這些東西。

---

## 進階（選用）：多台電腦共用

如果你在多台電腦上工作，可以把 `ClaudeHandoff` 資料夾做成**另一個私人（Private）GitHub 專案**，用 GitHub Desktop 同步：

1. 在 GitHub 建立新專案，**一定要選 Private**。
2. 用 GitHub Desktop 把 `ClaudeHandoff` 資料夾加入成這個專案。
3. 換電腦前 Commit + Push，到另一台電腦先 Pull。

注意：**不要**用這個公開的 claude-handoff 專案存資料。

---

## Claude Code 使用者

把 `claude-code/CLAUDE.md.snippet` 的內容貼到你專案的 `CLAUDE.md`。Claude Code 會在專案內的 `.handoff/HANDOFF.md` 自動存檔。
如果專案是公開的，記得把 `.handoff/` 加進 `.gitignore`。

---

## 常見問題 FAQ

**Q：Claude 沒有自動存檔怎麼辦？**
A：直接說「存檔」。也確認 handoff-save 技能有開啟、而且這個對話有連接 `ClaudeHandoff` 資料夾。

**Q：Claude 說找不到資料夾？**
A：每個新對話都要重新按 + → Add folder 連接。沒連接的話，Claude 會把交接檔內容顯示在對話裡，請你自己存成 `ClaudeHandoff\專案代號\HANDOFF.md`。

**Q：在網頁版（claude.ai）可以用嗎？**
A：技能可以用，但網頁版通常不能直接存取你電腦的資料夾。Claude 會把交接檔顯示在對話裡，你需要手動複製存檔，換帳號時再貼上。建議用桌面版。

**Q：可以同時用兩個帳號做同一個專案嗎？**
A：不建議。兩邊同時存檔會互相覆蓋。一次只在一個帳號上工作。

**Q：被中斷時還沒存過檔？**
A：複製舊對話最後一段，貼到新帳號，加一句「請用 handoff-load 規則整理並接續」。

**Q：交接檔寫錯了？**
A：用記事本直接改 `HANDOFF.md`，或告訴 Claude 哪裡不對。接續時 Claude 也會先檢查實際檔案，以實際狀態為準。

**Q：要怎麼移除？**
A：在每個帳號的 Skills 設定裡刪除三個技能，再刪掉 `ClaudeHandoff` 資料夾即可。

**Q：我修改了技能，要怎麼重新打包？**
A：安裝 Python 後執行 `python scripts\build-skills.py`，新的 zip 會出現在 `dist\`。

---

## English

**claude-handoff** lets you continue the same work across two Claude accounts (e.g. Team and Personal) after one hits its usage limit. There is no API to share memory or chats between accounts, so two Claude Skills make Claude write a checkpoint file (`HANDOFF.md`, plus an append-only `LOG.md`) to a local folder both accounts can reach through the desktop app's **Add folder**.

- **Install:** run `scripts/setup-windows.bat` (creates `%USERPROFILE%\ClaudeHandoff`); in **each** account upload `dist/handoff-save.zip`, `dist/handoff-load.zip` and `dist/skill-share.zip` under Settings → Capabilities/Skills (labels may vary); connect the folder in each new chat via **+ → Add folder**.
- **Use:** Claude checkpoints automatically at milestones. When cut off, switch accounts, open a new chat, connect the folder, and say "resume <project>" / 「接續 <專案名>」.
- **Limits:** not real-time sync — only the last checkpoint survives. If cut off before any checkpoint, paste the end of the old chat into the new one with "請用 handoff-load 規則整理並接續".
- **Privacy:** keep handoff data and shared skills out of this public repo (the `.gitignore` blocks common paths). Never store secrets. On Team accounts, follow your organization's policy; admins may disable skill uploads.
- **Share your own skills:** the `skill-share` skill exports your custom skills to `ClaudeHandoff/skills/` (with `INDEX.md`) and imports them in the other account (via a skill review card where available; otherwise zip them with `scripts/pack-shared-skills.bat` and upload manually).
- **Claude Code:** paste `claude-code/CLAUDE.md.snippet` into your project's `CLAUDE.md` (checkpoints go to `.handoff/`; gitignore it in public repos).
- Rebuild zips: `python scripts/build-skills.py` (stdlib only).

License: MIT © 2026 rjian-collab
