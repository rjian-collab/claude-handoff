@echo off
chcp 65001 >nul
setlocal
set "HANDOFF_DIR=%USERPROFILE%\ClaudeHandoff"

echo ============================================
echo   claude-handoff 安裝程式（Windows）
echo ============================================
echo.
echo 這個程式只會做一件事：建立交接資料夾
echo   %HANDOFF_DIR%
echo 不會安裝任何軟體，也不會上傳任何資料。
echo.

if exist "%HANDOFF_DIR%\" (
  echo [i] 資料夾已經存在，不會刪除裡面的任何檔案。
) else (
  mkdir "%HANDOFF_DIR%"
  if errorlevel 1 goto :fail
  echo [OK] 已建立資料夾。
)

> "%HANDOFF_DIR%\README.txt" (
  echo ClaudeHandoff 交接資料夾
  echo ========================
  echo 這裡存放 Claude 自動寫的交接檔，讓你在 Team 帳號和個人帳號之間接續同一份工作。
  echo.
  echo 結構：每個專案一個子資料夾
  echo   專案代號\HANDOFF.md  目前進度（每次存檔會覆蓋）
  echo   專案代號\LOG.md      存檔紀錄（只會往下加）
  echo.
  echo 使用方式：
  echo   1. 在 Claude 桌面版每個新對話，按 + 然後 Add folder，選這個資料夾。
  echo   2. 工作時 Claude 會自動存檔。
  echo   3. 換帳號後開新對話、連接這個資料夾，說：接續 專案名稱
  echo.
  echo 注意：這裡是你的私人資料，不要放到公開的 GitHub 專案裡。
  echo 不要在交接檔裡寫密碼、API 金鑰或 token。
)
if errorlevel 1 goto :fail
echo [OK] 已寫入 README.txt 說明檔。

echo.
echo 完成！下一步：
echo   1. 在 Claude 桌面版的「每個帳號」上傳 dist 資料夾裡的兩個 zip 技能檔。
echo   2. 開新對話時，按 + 選 Add folder，連接上面那個 ClaudeHandoff 資料夾。
echo.
echo 現在幫你打開資料夾...
start "" explorer "%HANDOFF_DIR%"
pause
exit /b 0

:fail
echo.
echo [錯誤] 建立失敗。請確認你有權限寫入 %USERPROFILE%，或把這個視窗截圖問 Claude。
pause
exit /b 1
