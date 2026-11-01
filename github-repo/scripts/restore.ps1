param(
    [string]$InstallDir = "",
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"

function Find-SKLauncher {
    param([string]$Hint)

    if ($Hint) {
        if (Test-Path (Join-Path $Hint "sklauncher.exe")) { return $Hint }
        throw "指定的目录里没有 sklauncher.exe：$Hint"
    }

    $default = Join-Path $env:LOCALAPPDATA "Programs\sklauncher"
    if (Test-Path (Join-Path $default "sklauncher.exe")) { return $default }

    $roots = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    foreach ($root in $roots) {
        if (-not (Test-Path $root)) { continue }
        foreach ($sub in Get-ChildItem $root -ErrorAction SilentlyContinue) {
            $p = Get-ItemProperty $sub.PSPath -ErrorAction SilentlyContinue
            if ($p -and $p.DisplayName -like "SKLauncher*") {
                if ($p.InstallLocation) {
                    $cand = Join-Path $p.InstallLocation "sklauncher.exe"
                    if (Test-Path $cand) { return $p.InstallLocation }
                }
                if ($p.UninstallString) {
                    $u = $p.UninstallString.Trim('"')
                    $d = Split-Path $u -Parent
                    if ($d -and (Test-Path (Join-Path $d "sklauncher.exe"))) { return $d }
                }
            }
        }
    }

    throw "没有找到 SKlauncher。请使用 -InstallDir 指定目录。"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  恢复 SKlauncher 原版" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$appDir = Find-SKLauncher -Hint $InstallDir
$exe = Join-Path $appDir "sklauncher.exe"
$asar = Join-Path $appDir "resources\app.asar"
$backupDir = Join-Path $appDir "zh-backup"

if (-not (Test-Path $backupDir)) {
    throw "没有找到备份目录：$backupDir"
}

$asarBackup = Get-ChildItem $backupDir -Filter "app.asar.*.orig" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
$exeBackup = Get-ChildItem $backupDir -Filter "sklauncher.exe.*.orig" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $asarBackup) {
    throw "没有找到 app.asar 备份，无法恢复。"
}

Get-Process sklauncher -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Copy-Item $asarBackup.FullName $asar -Force
Write-Host "已恢复原版 app.asar。"

if ($exeBackup) {
    Copy-Item $exeBackup.FullName $exe -Force
    Write-Host "已恢复原版 sklauncher.exe。"
}
else {
    Write-Host "没有找到 exe 备份，跳过。" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "恢复完成。" -ForegroundColor Green
Write-Host ""

if (-not $NoLaunch) {
    Start-Process $exe
}
