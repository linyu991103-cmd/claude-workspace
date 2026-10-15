# 在 Windows 上运行：拉取仓库，把 claude-home/ 里的记忆、设置和聊天记录还原到 %USERPROFILE%\.claude
# 用法（PowerShell）：  powershell -ExecutionPolicy Bypass -File .\sync-to-win.ps1
$ErrorActionPreference = 'Stop'

$RepoDir = $PSScriptRoot
$Src = Join-Path $RepoDir 'claude-home'
$Dest = Join-Path $env:USERPROFILE '.claude'

git -C $RepoDir pull --ff-only
if ($LASTEXITCODE -ne 0) { throw 'git pull 失败' }

if (-not (Test-Path $Src)) { Write-Host '✗ 仓库里还没有 claude-home，请先在 Mac 上运行 sync-from-mac.sh'; exit 1 }
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

# 全局记忆
if (Test-Path "$Src\CLAUDE.md") { Copy-Item "$Src\CLAUDE.md" $Dest -Force }

# 设置：Windows 已有 settings.json 时不覆盖（Mac 的路径/命令可能不适用），另存一份供对照
if (Test-Path "$Src\settings.json") {
    if (Test-Path "$Dest\settings.json") {
        Copy-Item "$Src\settings.json" "$Dest\settings.from-mac.json" -Force
        Write-Host '! 已有 settings.json，Mac 的设置另存为 settings.from-mac.json，请手动合并'
    } else {
        Copy-Item "$Src\settings.json" $Dest -Force
    }
}

# 自定义命令 / 技能 / 子代理
foreach ($d in 'commands', 'skills', 'agents') {
    if (Test-Path "$Src\$d") { Copy-Item "$Src\$d" $Dest -Recurse -Force }
}

# 各项目的记忆和聊天记录（按 Mac 的项目路径命名，原样保留）
if (Test-Path "$Src\projects") {
    New-Item -ItemType Directory -Force -Path "$Dest\projects" | Out-Null
    Copy-Item "$Src\projects\*" "$Dest\projects" -Recurse -Force
}

Write-Host "✓ 已还原到 $Dest"
