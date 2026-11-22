# claude-handoff 私人 GitHub 模式設定（PowerShell 版）
# 執行方式：在這個檔案上按右鍵 >「用 PowerShell 執行」
# 或：powershell -ExecutionPolicy Bypass -File .\setup-private-repo.ps1

$ErrorActionPreference = 'Continue'   # 用 $LASTEXITCODE 檢查外部指令
$Data = Join-Path $env:USERPROFILE 'ClaudeHandoff'
$Repo = 'claude-handoff-data'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Stop-Setup([string]$msg) {
    Write-Host ''
    Write-Host "[錯誤] $msg" -ForegroundColor Red
    Write-Host '請把這個視窗截圖問 Claude。'
    Read-Host '按 Enter 關閉視窗'
    exit 1
}
function Has-Command([string]$name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }
function Ask-YesNo([string]$q) { (Read-Host "$q （Y/N）") -match '^[Yy]' }

Write-Host '============================================'
Write-Host '  claude-handoff 私人 GitHub 模式設定'
Write-Host '============================================'
Write-Host "這個程式會把你的交接資料夾 $Data"
Write-Host "同步到你自己的「私人 Private」GitHub 專案 $Repo，"
Write-Host '讓手機或電腦關機時，Claude 也能讀到你的進度。只有你看得到這個專案。'
Read-Host '按 Enter 開始'

# 1. 檢查 git 和 gh
Write-Host "`n[1/6] 檢查需要的工具 git 和 GitHub CLI（gh）..."
$missing = @()
if (-not (Has-Command git)) { $missing += @{ Name = 'Git'; Id = 'Git.Git' } }
if (-not (Has-Command gh))  { $missing += @{ Name = 'GitHub CLI'; Id = 'GitHub.cli' } }
if ($missing.Count -gt 0) {
    foreach ($m in $missing) {
        Write-Host "[缺少] 找不到 $($m.Name)。"
        if (Ask-YesNo "要用 winget 自動安裝 $($m.Name) 嗎") {
            winget install --id $m.Id -e
        } else {
            Write-Host '請自行安裝：Git https://git-scm.com 、GitHub CLI https://cli.github.com'
        }
    }
    Write-Host "`n安裝完成後，請「關掉這個視窗」再重新執行這個程式（新安裝的程式要重開視窗才找得到）。"
    Read-Host '按 Enter 關閉視窗'
    exit 1
}
Write-Host '[OK] git 和 gh 都已安裝。' -ForegroundColor Green

# 2. 登入 GitHub
Write-Host "`n[2/6] 檢查 GitHub 登入狀態..."
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host '你還沒登入 GitHub。接下來：'
    Write-Host '  1. 問題請選預設值，直接按 Enter 即可。'
    Write-Host '  2. 畫面會顯示一組「一次性代碼」（例如 ABCD-1234），請先記下來。'
    Write-Host '  3. 按 Enter 後會打開瀏覽器，登入 GitHub 並輸入那組代碼，按授權。'
    gh auth login --hostname github.com --web --git-protocol https
    gh auth status *> $null
    if ($LASTEXITCODE -ne 0) { Stop-Setup 'GitHub 登入沒有成功，請再執行一次。' }
}
gh auth setup-git *> $null
$User = (gh api user --jq .login).Trim()
if (-not $User) { Stop-Setup '讀不到 GitHub 帳號名稱。' }
Write-Host "[OK] 已登入 GitHub，帳號：$User" -ForegroundColor Green

# 3. 建立私人 repo
Write-Host "`n[3/6] 檢查私人專案 $User/$Repo ..."
gh repo view "$User/$Repo" *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host '還沒有這個專案，現在建立「私人 Private」專案...'
    gh repo create "$User/$Repo" --private --description 'Private data for claude-handoff'
    if ($LASTEXITCODE -ne 0) { Stop-Setup '建立專案失敗。' }
    Write-Host '[OK] 已建立私人專案。' -ForegroundColor Green
} else {
    $vis = (gh repo view "$User/$Repo" --json visibility --jq .visibility).Trim()
    if ($vis -ne 'PRIVATE') {
        Stop-Setup "$User/$Repo 已存在，但不是私人專案（目前是 $vis）。為了保護資料不會繼續；請到 GitHub 的 Settings 改成 Private。"
    }
    Write-Host '[OK] 專案已存在，而且是私人的。' -ForegroundColor Green
}

# 4. 準備資料夾
Write-Host "`n[4/6] 準備交接資料夾..."
New-Item -ItemType Directory -Force -Path (Join-Path $Data 'skills') | Out-Null
Set-Location -LiteralPath $Data
$needPush = $false
if (-not (Test-Path -LiteralPath (Join-Path $Data '.git'))) {
    git init -b main
    if ($LASTEXITCODE -ne 0) { Stop-Setup 'git init 失敗。' }
}
git remote get-url origin *> $null
if ($LASTEXITCODE -ne 0) {
    git remote add origin "https://github.com/$User/$Repo.git"
    $needPush = $true
} else {
    Write-Host '[OK] 這個資料夾已經設定好同步了，不需要再設定。' -ForegroundColor Green
}
git config user.name *> $null
if ($LASTEXITCODE -ne 0) { git config user.name $User }
git config user.email *> $null
if ($LASTEXITCODE -ne 0) { git config user.email "$User@users.noreply.github.com" }

$utf8 = New-Object System.Text.UTF8Encoding($false)
if (-not (Test-Path 'README.md')) {
    $readme = @'
# claude-handoff-data（私人資料）

這是 claude-handoff 工具的「私人」資料專案，請保持 Private。

- 每個專案一個資料夾：專案代號/HANDOFF.md 目前進度、專案代號/LOG.md 存檔紀錄
- skills/：在兩個 Claude 帳號之間共用的自製技能

不要放密碼、API 金鑰或 token。
'@
    [System.IO.File]::WriteAllText((Join-Path $Data 'README.md'), $readme, $utf8)
}
function Add-Line([string]$file, [string]$line) {
    $path = Join-Path $Data $file
    $lines = @(); if (Test-Path $path) { $lines = Get-Content -LiteralPath $path }
    if ($lines -notcontains $line) { [System.IO.File]::AppendAllText($path, "$line`r`n", $utf8) }
}
Add-Line '.gitignore' '_zips/'
Add-Line '.gitignore' '.tools/'
Add-Line '.gitattributes' 'LOG.md merge=union'

# 5. 第一次上傳
if ($needPush) {
    Write-Host "`n[5/6] 第一次上傳到 GitHub..."
    git add -A
    git diff --cached --quiet
    if ($LASTEXITCODE -ne 0) { git commit -q -m 'Initial handoff data' }
    $remoteMain = git ls-remote --heads origin main
    if ($remoteMain) {
        git pull --rebase origin main --allow-unrelated-histories
        if ($LASTEXITCODE -ne 0) { Stop-Setup '下載遠端資料失敗。' }
    }
    git push -u origin main
    if ($LASTEXITCODE -ne 0) { Stop-Setup '上傳失敗。' }
    Write-Host '[OK] 上傳完成。' -ForegroundColor Green
}

# 6. 自動同步
Write-Host "`n[6/6] 自動同步設定"
$tools = Join-Path $Data '.tools'
New-Item -ItemType Directory -Force -Path $tools | Out-Null
$syncBat = Join-Path $tools 'sync-handoff.bat'
Copy-Item -LiteralPath (Join-Path $ScriptDir 'sync-handoff.bat') -Destination $syncBat -Force
Write-Host "已把同步程式複製到 $syncBat"
Write-Host '要不要讓電腦「每 10 分鐘」自動同步一次？建議選 Y。同步時可能會短暫閃過黑色視窗，這是正常的。'
if (Ask-YesNo '請輸入 Y 或 N') {
    schtasks /Create /SC MINUTE /MO 10 /TN 'ClaudeHandoffSync' /TR "`"$syncBat`" /quiet" /F
    if ($LASTEXITCODE -ne 0) { Stop-Setup '建立排程失敗。' }
    Write-Host '[OK] 已建立自動同步排程 ClaudeHandoffSync（不要時執行 remove-auto-sync.bat）。' -ForegroundColor Green
} else {
    Write-Host "沒有建立自動同步。需要時請手動雙擊 $syncBat"
}

Write-Host "`n============================================"
Write-Host '全部完成！'
Write-Host "私人專案：https://github.com/$User/$Repo"
Write-Host '離開電腦或關機前，建議手動執行一次 sync-handoff.bat，確保最新進度已上傳。'
Write-Host '============================================'
Read-Host '按 Enter 關閉視窗'
