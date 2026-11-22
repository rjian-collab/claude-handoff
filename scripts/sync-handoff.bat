@echo off
chcp 65001 >nul
setlocal EnableExtensions
rem 同步 ClaudeHandoff 資料夾和私人 GitHub 專案
rem 用法：sync-handoff.bat        （顯示訊息）
rem       sync-handoff.bat /quiet （排程用，不顯示、不暫停，錯誤寫進 .tools\sync-log.txt）
set "DATA=%USERPROFILE%\ClaudeHandoff"
set "QUIET="
if /i "%~1"=="/quiet" set "QUIET=1"
set "LOG=%DATA%\.tools\sync-log.txt"
if defined QUIET (set "SAY=rem") else (set "SAY=echo")
if defined QUIET (set "Q=>nul 2>&1") else (set "Q=")

if not exist "%DATA%\.git\" goto :not_repo
cd /d "%DATA%" || goto :not_repo

%SAY% 同步中：%DATA%
git add -A %Q%
git diff --cached --quiet
if errorlevel 1 git commit -q -m "auto-sync %date% %time:~0,8% %COMPUTERNAME%" %Q%

rem 同一段內容兩邊都改時：以這台電腦較新的版本為準；LOG.md 兩邊的紀錄都保留
git pull --rebase --autostash -X theirs origin main %Q%
if errorlevel 1 goto :pull_fail
git push -q origin main %Q%
if errorlevel 1 goto :push_fail
%SAY% [OK] 同步完成。
if not defined QUIET pause
exit /b 0

:pull_fail
git rebase --abort >nul 2>&1
call :report "下載 pull 失敗。可能沒有網路，或兩邊的修改衝突。"
exit /b 1
:push_fail
call :report "上傳 push 失敗。可能沒有網路或登入過期，請重新執行 setup-private-repo.bat。"
exit /b 1
:not_repo
call :report "%DATA% 還沒設定同步，請先執行 setup-private-repo.bat。"
exit /b 1

:report
if defined QUIET (
  if exist "%DATA%\.tools\" echo %date% %time:~0,8% %~1>> "%LOG%"
) else (
  echo [錯誤] %~1
  pause
)
exit /b 0
