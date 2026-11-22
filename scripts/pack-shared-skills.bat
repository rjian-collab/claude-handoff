@echo off
chcp 65001 >nul
setlocal
set "SHARED=%USERPROFILE%\ClaudeHandoff\skills"
if not "%~1"=="" set "SHARED=%~1"

echo ============================================
echo   打包共用技能（給手動上傳用）
echo ============================================
echo 來源資料夾：%SHARED%
echo.

set "PY="
where py >nul 2>nul && set "PY=py -3"
if not defined PY where python >nul 2>nul && set "PY=python"
if not defined PY goto :nopython

%PY% "%~dp0pack-shared-skills.py" "%SHARED%"
if errorlevel 1 goto :fail
echo.
echo 完成！zip 檔在：%SHARED%\_zips
echo 到 Claude 設定裡的 Skills 頁面，上傳這些 zip 檔即可。
start "" explorer "%SHARED%\_zips"
pause
exit /b 0

:nopython
echo [提示] 這台電腦沒有安裝 Python，所以無法自動打包。
echo 你可以改用手動方式：
echo   1. 打開 %SHARED%
echo   2. 在某個技能資料夾上按右鍵，選「壓縮成 ZIP 檔」
echo      Windows 11 可能要先點「顯示其他選項」，再選「傳送到」然後「壓縮的 zipped 資料夾」
echo   3. 到 Claude 設定裡的 Skills 頁面上傳這個 zip 檔。
echo 或者到 https://www.python.org 安裝 Python 後再執行一次。
pause
exit /b 1

:fail
echo.
echo [錯誤] 打包失敗。請確認上面的資料夾存在、Python 已正確安裝，或把這個視窗截圖問 Claude。
pause
exit /b 1
