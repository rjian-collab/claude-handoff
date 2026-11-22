@echo off
chcp 65001 >nul
echo 移除每 10 分鐘自動同步的排程 ClaudeHandoffSync ...
schtasks /Delete /TN "ClaudeHandoffSync" /F
if errorlevel 1 (
  echo [i] 找不到這個排程，可能本來就沒有建立。
) else (
  echo [OK] 已移除。你的資料和私人 GitHub 專案都不會被刪除。
)
pause
