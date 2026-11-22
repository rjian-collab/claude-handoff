# claude-handoff 安裝程式（PowerShell 版）
# 執行方式：在這個檔案上按右鍵 >「用 PowerShell 執行」
# 或在 PowerShell 輸入：powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1

$ErrorActionPreference = 'Stop'
$HandoffDir = Join-Path $env:USERPROFILE 'ClaudeHandoff'

Write-Host '============================================'
Write-Host '  claude-handoff 安裝程式（Windows）'
Write-Host '============================================'
Write-Host ''
Write-Host '這個程式只會做一件事：建立交接資料夾'
Write-Host "  $HandoffDir"
Write-Host '不會安裝任何軟體，也不會上傳任何資料。'
Write-Host ''

try {
    if (Test-Path -LiteralPath $HandoffDir) {
        Write-Host '[i] 資料夾已經存在，不會刪除裡面的任何檔案。'
    } else {
        New-Item -ItemType Directory -Path $HandoffDir | Out-Null
        Write-Host '[OK] 已建立資料夾。' -ForegroundColor Green
    }

    $readme = @'
ClaudeHandoff 交接資料夾
========================
這裡存放 Claude 自動寫的交接檔，讓你在 Team 帳號和個人帳號之間接續同一份工作。

結構：每個專案一個子資料夾
  專案代號\HANDOFF.md  目前進度（每次存檔會覆蓋）
  專案代號\LOG.md      存檔紀錄（只會往下加）

使用方式：
  1. 在 Claude 桌面版每個新對話，按 + 然後 Add folder，選這個資料夾。
  2. 工作時 Claude 會自動存檔。
  3. 換帳號後開新對話、連接這個資料夾，說：接續 專案名稱

注意：這裡是你的私人資料，不要放到公開的 GitHub 專案裡。
不要在交接檔裡寫密碼、API 金鑰或 token。
'@
    Set-Content -LiteralPath (Join-Path $HandoffDir 'README.txt') -Value $readme -Encoding UTF8
    Write-Host '[OK] 已寫入 README.txt 說明檔。' -ForegroundColor Green

    Write-Host ''
    Write-Host '完成！下一步：'
    Write-Host '  1. 在 Claude 桌面版的「每個帳號」上傳 dist 資料夾裡的兩個 zip 技能檔。'
    Write-Host '  2. 開新對話時，按 + 選 Add folder，連接上面那個 ClaudeHandoff 資料夾。'
    Write-Host ''
    Write-Host '現在幫你打開資料夾...'
    Start-Process explorer.exe -ArgumentList "`"$HandoffDir`""
} catch {
    Write-Host ''
    Write-Host "[錯誤] 建立失敗：$($_.Exception.Message)" -ForegroundColor Red
    Write-Host '請確認你有權限寫入使用者資料夾，或把這個視窗截圖問 Claude。'
}
Read-Host '按 Enter 關閉視窗'
