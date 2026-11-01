param(
    [string]$InstallDir = "",
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"
$patchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchedAsar = Join-Path $patchDir "app.asar"

$OrigSize = 50197475
$PatchedSize = 49147798

function Find-SKLauncher {
    param([string]$Hint)

    if ($Hint) {
        if (Test-Path (Join-Path $Hint "sklauncher.exe")) { return $Hint }
        throw "指定的目录里没有 sklauncher.exe：$Hint"
    }

    $default = Join-Path $env:LOCALAPPDATA "Programs\sklauncher"
    if (Test-Path (Join-Path $default "sklauncher.exe")) { return $default }

    $pf = $env:ProgramFiles
    if ($pf -and (Test-Path (Join-Path $pf "SKlauncher\sklauncher.exe"))) { return (Join-Path $pf "SKlauncher") }
    $pf86 = ${env:ProgramFiles(x86)}
    if ($pf86 -and (Test-Path (Join-Path $pf86 "SKLauncher\sklauncher.exe"))) { return (Join-Path $pf86 "SKLauncher") }

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

    throw "没有找到 SKlauncher。请先安装 SKlauncher 4.0.55，或使用 -InstallDir 指定目录。"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SKlauncher 简体中文补丁 4.0.55" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (-not (Test-Path $patchedAsar)) {
    throw "补丁文件 app.asar 不存在，请把压缩包完整解压后再运行。"
}

$appDir = Find-SKLauncher -Hint $InstallDir
$exe = Join-Path $appDir "sklauncher.exe"
$asar = Join-Path $appDir "resources\app.asar"

Write-Host "安装目录：$appDir"

if (-not (Test-Path $asar)) {
    throw "没有找到 resources\app.asar，安装目录可能不完整。"
}

$currentSize = (Get-Item $asar).Length
$alreadyPatched = $false

if ($currentSize -eq $PatchedSize) {
    Write-Host "检测到已经是中文版，跳过替换。" -ForegroundColor Yellow
    $alreadyPatched = $true
}
elseif ($currentSize -ne $OrigSize) {
    throw "当前 app.asar 大小是 $currentSize 字节，不是 SKlauncher 4.0.55 原版（$OrigSize 字节）。请先安装 4.0.55 原版后再运行补丁。"
}

Get-Process sklauncher -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

$backupDir = Join-Path $appDir "zh-backup"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not $alreadyPatched) {
    $asarBackup = Join-Path $backupDir "app.asar.$stamp.orig"
    Copy-Item $asar $asarBackup -Force
    Write-Host "已备份原版 app.asar。"
    Copy-Item $patchedAsar $asar -Force
    Write-Host "已写入中文 app.asar。" -ForegroundColor Green
}

$exeBackup = Join-Path $backupDir "sklauncher.exe.$stamp.orig"
Copy-Item $exe $exeBackup -Force

Write-Host "正在关闭 asar 完整性校验..."
$bytes = [System.IO.File]::ReadAllBytes($exe)
$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$text = $latin1.GetString($bytes)
$sentinel = "dL7pKGdnNz796PbbjQWNKmHXBZaB9tsX"
$idx = $text.IndexOf($sentinel)

if ($idx -lt 0) {
    throw "无法在 sklauncher.exe 中定位 asar 校验开关。请确认这是 SKlauncher 4.0.55 的官方 exe。"
}

$stateOffset = $idx + 38
$state = $bytes[$stateOffset]

if ($state -eq 0x31) {
    $bytes[$stateOffset] = 0x30
    try {
        [System.IO.File]::WriteAllBytes($exe, $bytes)
    }
    catch {
        throw "无法修改 sklauncher.exe。请右键以管理员身份运行，或确认启动器已完全退出。"
    }
    Write-Host "已关闭 asar 校验。" -ForegroundColor Green
}
elseif ($state -eq 0x30) {
    Write-Host "asar 校验已经是关闭状态。"
}
else {
    throw ("无法识别的 asar 校验状态：0x{0:X2}" -f $state)
}

Write-Host ""
Write-Host "安装完成，首次启动会自动切换到中文。" -ForegroundColor Green
Write-Host "以后可以在 设置 -> 通用 -> 语言 中切换语言。"
Write-Host ""

if (-not $NoLaunch) {
    Start-Process $exe
}
