@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "DATA=%USERPROFILE%\ClaudeHandoff"
set "REPO=claude-handoff-data"
set "SCRIPTDIR=%~dp0"

echo ============================================
echo   claude-handoff 私人 GitHub 模式設定
echo ============================================
echo 這個程式會把你的交接資料夾
echo   %DATA%
echo 同步到你自己的「私人 Private」GitHub 專案 %REPO%，
echo 讓手機或電腦關機時，Claude 也能讀到你的進度。
echo 只有你看得到這個專案，不會公開。
echo.
pause

rem ---------- 1. 檢查 git 和 gh ----------
echo.
echo [1/6] 檢查需要的工具 git 和 GitHub CLI 也就是 gh ...
where git >nul 2>nul
if errorlevel 1 goto :need_git
where gh >nul 2>nul
if errorlevel 1 goto :need_gh
echo [OK] git 和 gh 都已安裝。

rem ---------- 2. 登入 GitHub ----------
echo.
echo [2/6] 檢查 GitHub 登入狀態...
gh auth status >nul 2>nul
if not errorlevel 1 goto :logged_in
echo 你還沒登入 GitHub。接下來：
echo   1. 問題請選預設值，直接按 Enter 即可。
echo   2. 畫面會顯示一組「一次性代碼」，例如 ABCD-1234，請先記下來。
echo   3. 按 Enter 後會打開瀏覽器，登入 GitHub 並輸入那組代碼，按授權。
echo.
gh auth login --hostname github.com --web --git-protocol https
gh auth status >nul 2>nul
if errorlevel 1 goto :fail_login
:logged_in
echo [OK] 已登入 GitHub。
gh auth setup-git >nul 2>nul

for /f "usebackq delims=" %%U in (`gh api user --jq .login`) do set "GHUSER=%%U"
if not defined GHUSER goto :fail_login
echo     帳號：%GHUSER%

rem ---------- 3. 建立私人 repo ----------
echo.
echo [3/6] 檢查私人專案 %GHUSER%/%REPO% ...
gh repo view "%GHUSER%/%REPO%" >nul 2>nul
if not errorlevel 1 goto :repo_exists
echo 還沒有這個專案，現在建立「私人 Private」專案...
gh repo create "%GHUSER%/%REPO%" --private --description "Private data for claude-handoff"
if errorlevel 1 goto :fail
echo [OK] 已建立私人專案。
goto :repo_ok
:repo_exists
set "VIS="
for /f "usebackq delims=" %%V in (`gh repo view "%GHUSER%/%REPO%" --json visibility --jq .visibility`) do set "VIS=%%V"
if /i not "%VIS%"=="PRIVATE" goto :not_private
echo [OK] 專案已存在，而且是私人的。
:repo_ok

rem ---------- 4. 準備資料夾 ----------
echo.
echo [4/6] 準備交接資料夾...
if not exist "%DATA%\" mkdir "%DATA%"
if not exist "%DATA%\skills\" mkdir "%DATA%\skills"
cd /d "%DATA%" || goto :fail

if not exist "%DATA%\.git\" goto :init_repo
git remote get-url origin >nul 2>nul
if errorlevel 1 goto :add_remote
echo [OK] 這個資料夾已經設定好同步了，不需要再設定。
goto :set_identity

:init_repo
git init -b main
if errorlevel 1 goto :fail
:add_remote
git remote add origin "https://github.com/%GHUSER%/%REPO%.git"
if errorlevel 1 goto :fail
set "NEED_PUSH=1"

:set_identity
rem 如果還沒設定 git 的名字和 email，只在這個資料夾設定
git config user.name >nul 2>nul
if errorlevel 1 git config user.name "%GHUSER%"
git config user.email >nul 2>nul
if errorlevel 1 git config user.email "%GHUSER%@users.noreply.github.com"

if exist "README.md" goto :readme_done
> "README.md" (
  echo # claude-handoff-data（私人資料）
  echo.
  echo 這是 claude-handoff 工具的「私人」資料專案，請保持 Private。
  echo.
  echo - 每個專案一個資料夾：專案代號/HANDOFF.md 目前進度、專案代號/LOG.md 存檔紀錄
  echo - skills/：在兩個 Claude 帳號之間共用的自製技能
  echo.
  echo 不要放密碼、API 金鑰或 token。
)
:readme_done
if not exist ".gitignore" type nul > ".gitignore"
findstr /x /c:"_zips/" ".gitignore" >nul 2>nul || echo _zips/>> ".gitignore"
findstr /x /c:".tools/" ".gitignore" >nul 2>nul || echo .tools/>> ".gitignore"
if not exist ".gitattributes" type nul > ".gitattributes"
findstr /x /c:"LOG.md merge=union" ".gitattributes" >nul 2>nul || echo LOG.md merge=union>> ".gitattributes"

if not defined NEED_PUSH goto :autosync

rem ---------- 5. 第一次上傳 ----------
echo.
echo [5/6] 第一次上傳到 GitHub...
git add -A
git diff --cached --quiet
if errorlevel 1 git commit -q -m "Initial handoff data"
set "REMOTE_MAIN="
for /f "usebackq delims=" %%H in (`git ls-remote --heads origin main`) do set "REMOTE_MAIN=1"
if not defined REMOTE_MAIN goto :first_push
git pull --rebase origin main --allow-unrelated-histories
if errorlevel 1 goto :fail
:first_push
git push -u origin main
if errorlevel 1 goto :fail
echo [OK] 上傳完成。

rem ---------- 6. 自動同步 ----------
:autosync
echo.
echo [6/6] 自動同步設定
if not exist "%DATA%\.tools\" mkdir "%DATA%\.tools"
copy /y "%SCRIPTDIR%sync-handoff.bat" "%DATA%\.tools\sync-handoff.bat" >nul
if errorlevel 1 goto :fail
echo 已把同步程式複製到 %DATA%\.tools\sync-handoff.bat
echo.
echo 要不要讓電腦「每 10 分鐘」自動同步一次？
echo 建議選 Y。同步時可能會短暫閃過一個黑色視窗，這是正常的。
choice /C YN /M "請按 Y 或 N"
if errorlevel 2 goto :no_autosync
schtasks /Create /SC MINUTE /MO 10 /TN "ClaudeHandoffSync" /TR "\"%DATA%\.tools\sync-handoff.bat\" /quiet" /F
if errorlevel 1 goto :fail
echo [OK] 已建立自動同步排程 ClaudeHandoffSync。
echo     不想要時，執行 remove-auto-sync.bat 即可移除。
goto :done
:no_autosync
echo 沒有建立自動同步。需要同步時，請手動雙擊：
echo   %DATA%\.tools\sync-handoff.bat

:done
echo.
echo ============================================
echo 全部完成！
echo 私人專案：https://github.com/%GHUSER%/%REPO%
echo 離開電腦或關機前，建議手動執行一次 sync-handoff.bat，確保最新進度已上傳。
echo ============================================
pause
exit /b 0

:need_git
echo [缺少] 找不到 git。
choice /C YN /M "要用 winget 自動安裝 Git 嗎"
if errorlevel 2 goto :manual_install
winget install --id Git.Git -e
goto :reopen
:need_gh
echo [缺少] 找不到 GitHub CLI，也就是 gh。
choice /C YN /M "要用 winget 自動安裝 GitHub CLI 嗎"
if errorlevel 2 goto :manual_install
winget install --id GitHub.cli -e
goto :reopen
:reopen
echo.
echo 安裝完成後，請「關掉這個視窗」，再重新雙擊 setup-private-repo.bat。
echo 因為新安裝的程式要重開視窗才找得到。
pause
exit /b 1
:manual_install
echo 請自行安裝：Git https://git-scm.com 和 GitHub CLI https://cli.github.com
echo 安裝後再執行一次這個程式。
pause
exit /b 1

:not_private
echo.
echo [停止] %GHUSER%/%REPO% 已存在，但「不是私人」專案，目前是：%VIS%
echo 為了保護你的資料，這個程式不會繼續。
echo 請到 GitHub 專案的 Settings 把它改成 Private，或刪除後再執行一次。
pause
exit /b 1

:fail_login
echo.
echo [錯誤] GitHub 登入沒有成功。請再執行一次，或把這個視窗截圖問 Claude。
pause
exit /b 1

:fail
echo.
echo [錯誤] 上一個步驟失敗了。請把這個視窗截圖問 Claude。
pause
exit /b 1
