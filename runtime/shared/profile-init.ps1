$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")
$outFile = Join-Path $repoRoot "profile.local.yaml"
$templateFile = Join-Path $repoRoot "profile.template.yaml"
$agentsTemplate = Join-Path $repoRoot "AGENTS.template.md"
$defaultWorkspace = Join-Path $repoRoot "workspace"

# --- helpers ---

function Banner($Title) {
  Write-Output ""
  Write-Output "========================================"
  Write-Output "  $Title"
  Write-Output "========================================"
  Write-Output ""
}

function Info($Message) {
  Write-Output "[INFO] $Message"
}

function Detect-Lang {
  $culture = (Get-Culture).Name
  switch -Wildcard ($culture) {
    "zh*" { return "zh-CN" }
    "en*" { return "en-US" }
    "ja*" { return "ja-JP" }
    "ko*" { return "ko-KR" }
    default { return "zh-CN" }
  }
}

function Detect-Tz {
  try {
    return (Get-TimeZone).Id
  } catch {
    return "Asia/Shanghai"
  }
}

function Sync-AgentFiles($ws) {
  $agentsFile = Join-Path $ws "AGENTS.md"
  $claudeFile = Join-Path $ws "CLAUDE.md"

  if ((-not (Test-Path $agentsFile)) -and (-not (Test-Path $claudeFile))) {
    Copy-Item $agentsTemplate $agentsFile -Force
    Copy-Item $agentsFile $claudeFile -Force
    Info "已创建 AGENTS.md 与 CLAUDE.md"
    return
  }

  if ((Test-Path $agentsFile) -and (-not (Test-Path $claudeFile))) {
    Copy-Item $agentsFile $claudeFile -Force
    Info "已从 AGENTS.md 同步 CLAUDE.md"
    return
  }

  if ((Test-Path $claudeFile) -and (-not (Test-Path $agentsFile))) {
    Copy-Item $claudeFile $agentsFile -Force
    Info "已从 CLAUDE.md 同步 AGENTS.md"
    return
  }

  $agentsHash = (Get-FileHash $agentsFile -Algorithm SHA256).Hash
  $claudeHash = (Get-FileHash $claudeFile -Algorithm SHA256).Hash
  if ($agentsHash -ne $claudeHash) {
    $agentsTime = (Get-Item $agentsFile).LastWriteTimeUtc
    $claudeTime = (Get-Item $claudeFile).LastWriteTimeUtc
    if ($agentsTime -ge $claudeTime) {
      Copy-Item $agentsFile $claudeFile -Force
      Info "检测到差异，已以 AGENTS.md 覆盖 CLAUDE.md"
    } else {
      Copy-Item $claudeFile $agentsFile -Force
      Info "检测到差异，已以 CLAUDE.md 覆盖 AGENTS.md"
    }
  }
}

function Fill-AgentsField($File, $Field, $Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return }
  $content = Get-Content $File -Raw -Encoding UTF8
  $content = $content -replace "(?m)^(\*\*${Field}\*\*：)$", "`${1}${Value}"
  Set-Content -Path $File -Value $content -Encoding UTF8 -NoNewline
}

# ============================================================
# Step 0: 欢迎
# ============================================================

Banner "AI-Avatar 初始化向导"
Write-Output @"
欢迎使用 AI-Avatar！本向导将引导你完成所有配置：

  1. 检查依赖（Docker / Git）
  2. 设置工作目录
  3. 填写个人画像
  4. 选择 AI 引擎（Claude / Codex）
  5. 配置 API 密钥
  6. (可选) 配置 GitHub Token
  7. (可选) 安装定时任务
  8. 完成！

"@

# ============================================================
# Step 1: 依赖检查
# ============================================================

Banner "Step 1/8: 依赖检查"
& (Join-Path $repoRoot "runtime/shared/bootstrap.ps1")

# ============================================================
# Step 2: workspace 路径
# ============================================================

Banner "Step 2/8: 设置工作目录"
Write-Output "AI 分身运行在 Docker 容器中，只能访问这个目录下的文件。"
Write-Output "需要分身处理的文件请放到此目录下，分身也不会触及目录外的任何文件。"
Write-Output ""
$Workspace = Read-Host "workspace 路径 (回车使用默认: $defaultWorkspace)"
if ([string]::IsNullOrWhiteSpace($Workspace)) { $Workspace = $defaultWorkspace }

$syncSpace = Join-Path $Workspace "SyncSpace"
$archiveDir = Join-Path $syncSpace "沟通归档"
New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null
$ideasFile = Join-Path $syncSpace "主身想法.txt"
$commFile = Join-Path $syncSpace "主分身沟通.txt"
if (-not (Test-Path $ideasFile)) { New-Item -ItemType File -Path $ideasFile | Out-Null }
if (-not (Test-Path $commFile)) { New-Item -ItemType File -Path $commFile | Out-Null }
Sync-AgentFiles $Workspace
Info "工作目录已就绪: $Workspace"

# ============================================================
# Step 3: 个人画像
# ============================================================

$profileExisted = Test-Path $outFile

if ($profileExisted) {
  Banner "Step 3/8: 个人画像（已有配置，跳过）"
  Info "检测到 $outFile 已存在，跳过画像填写。"
} else {
  Banner "Step 3/8: 个人画像"

  Write-Output "🔒 隐私说明：你填写的所有信息仅保存在本机文件中，不会上传至任何服务器。"
  Write-Output "   profile.local.yaml 和 AGENTS.md 均已加入 .gitignore，不会被提交到代码仓库。"
  Write-Output ""

  # 3a: 基本画像 → profile.local.yaml
  Write-Output "--- 基本信息（写入 profile.local.yaml）---"
  $pName = Read-Host "昵称 (默认: Your Alias)"
  $pRole = Read-Host "角色/职位 (默认: Your Role)"
  if ([string]::IsNullOrWhiteSpace($pName)) { $pName = "Your Alias" }
  if ([string]::IsNullOrWhiteSpace($pRole)) { $pRole = "Your Role" }

  $autoLang = Detect-Lang
  $autoTz = Detect-Tz
  Info "自动检测 → 语言: $autoLang，时区: $autoTz"

  @"
profile:
  name: "$pName"
  language: "$autoLang"
  timezone: "$autoTz"

work:
  role: "$pRole"
  goals:
    - "Goal A"
    - "Goal B"

preferences:
  communication_style: "direct"
  output_length: "short"
"@ | Set-Content -Encoding UTF8 $outFile

  Info "已生成 $outFile"
  Info "可参考模板自行补充更多字段: $templateFile"

  # 3b: 身份概览 → AGENTS.md（全部可跳过）
  Write-Output ""
  Write-Output "--- 身份概览（写入 AGENTS.md，全部可跳过，直接回车跳过）---"
  $idName = Read-Host "姓名"
  $idGender = Read-Host "性别"
  $idHometown = Read-Host "家乡"
  $idLocation = Read-Host "现居"
  $idCareer = Read-Host "职业"
  $idCompany = Read-Host "公司"
  $idPersonality = Read-Host "人格(如 INTJ)"

  $agentsFile = Join-Path $Workspace "AGENTS.md"
  if (Test-Path $agentsFile) {
    Fill-AgentsField $agentsFile "姓名" $idName
    Fill-AgentsField $agentsFile "性别" $idGender
    Fill-AgentsField $agentsFile "家乡" $idHometown
    Fill-AgentsField $agentsFile "现居" $idLocation
    Fill-AgentsField $agentsFile "职业" $idCareer
    Fill-AgentsField $agentsFile "公司" $idCompany
    Fill-AgentsField $agentsFile "人格" $idPersonality

    $anyFilled = -not [string]::IsNullOrWhiteSpace("$idName$idGender$idHometown$idLocation$idCareer$idCompany$idPersonality")
    if ($anyFilled) {
      $content = Get-Content $agentsFile -Raw -Encoding UTF8
      $content = $content -replace "(?m)^> 请用户补充个人实际信息后删除本行。\r?\n", ""
      Set-Content -Path $agentsFile -Value $content -Encoding UTF8 -NoNewline
    }
    Copy-Item $agentsFile (Join-Path $Workspace "CLAUDE.md") -Force
    Info "已更新 AGENTS.md 身份概览"
  }
}

# ============================================================
# Step 4: 选择引擎
# ============================================================

Banner "Step 4/8: 选择 AI 引擎"
Write-Output "  1) Claude  (Anthropic)"
Write-Output "  2) Codex   (OpenAI)"
Write-Output ""
$engineChoice = Read-Host "输入序号 (默认: 1)"
if ([string]::IsNullOrWhiteSpace($engineChoice)) { $engineChoice = "1" }

switch ($engineChoice) {
  "2" { $engine = "codex" }
  default { $engine = "claude" }
}
Info "已选择引擎: $engine"

# ============================================================
# Step 5: 构建 Docker + 配置密钥
# ============================================================

Banner "Step 5/8: 配置密钥"

$dockerScript = Join-Path $repoRoot "runtime/$engine/$engine-docker"
$env:AVATAR_WORKSPACE_DIR = $Workspace

Write-Output "正在构建 Docker 镜像（首次较慢）..."
& bash $dockerScript build

if ($engine -eq "claude") {
  Write-Output ""
  Write-Output "获取 Anthropic API Key 的步骤："
  Write-Output "  1. 打开 https://console.anthropic.com/"
  Write-Output "  2. 注册/登录 → 进入 Settings → API Keys"
  Write-Output "  3. 创建一个新的 Key，复制下来"
  Write-Output ""
  $doToken = Read-Host "是否现在配置 API Key？(Y/n)"
  if ([string]::IsNullOrWhiteSpace($doToken)) { $doToken = "Y" }
  if ($doToken -match "^[Yy]") {
    & bash $dockerScript set-token
  } else {
    Info "跳过。后续可运行: bash $dockerScript set-token"
  }

  Write-Output ""
  $doBase = Read-Host "是否需要配置自定义 Base URL（中转/代理）？(y/N)"
  if ([string]::IsNullOrWhiteSpace($doBase)) { $doBase = "N" }
  if ($doBase -match "^[Yy]") {
    & bash $dockerScript set-base-url
  }
} else {
  Write-Output ""
  Write-Output "Codex 使用设备认证流程："
  Write-Output "  运行后会给出一个 URL 和验证码"
  Write-Output "  在浏览器中打开该 URL 并输入验证码即可"
  Write-Output ""
  $doLogin = Read-Host "是否现在进行设备登录？(Y/n)"
  if ([string]::IsNullOrWhiteSpace($doLogin)) { $doLogin = "Y" }
  if ($doLogin -match "^[Yy]") {
    & bash $dockerScript login-device
  } else {
    Info "跳过。后续可运行: bash $dockerScript login-device"
  }
}

# ============================================================
# Step 6: GitHub Token (可选)
# ============================================================

Banner "Step 6/8: GitHub Token（可选）"
Write-Output "如果你希望分身能访问你的 GitHub 仓库（读写代码、管理 Issue 等），"
Write-Output "需要配置 GitHub Personal Access Token。"
Write-Output "不需要可直接跳过。"
Write-Output ""
$doGh = Read-Host "是否现在配置 GitHub Token？(y/N)"
if ([string]::IsNullOrWhiteSpace($doGh)) { $doGh = "N" }
if ($doGh -match "^[Yy]") {
  & bash $dockerScript set-github-token
}

# ============================================================
# Step 7: 定时任务 (可选)
# ============================================================

Banner "Step 7/8: 定时任务（可选）"
Write-Output "安装定时任务后，分身会每天自动启动一次。"
Write-Output ""
$doCron = Read-Host "是否安装定时任务？(y/N)"
if ([string]::IsNullOrWhiteSpace($doCron)) { $doCron = "N" }
if ($doCron -match "^[Yy]") {
  $cronHour = Read-Host "每天几点运行？(0-23，默认 9)"
  if ([string]::IsNullOrWhiteSpace($cronHour)) { $cronHour = "9" }
  & (Join-Path $repoRoot "runtime/$engine/$engine-cron-install.ps1") -Hour ([int]$cronHour)
}

# ============================================================
# Step 8: 完成汇总
# ============================================================

Banner "Step 8/8: 初始化完成！"

Write-Output @"
已生成 / 更新的文件:
  - $outFile
  - $(Join-Path $Workspace "AGENTS.md")
  - $(Join-Path $Workspace "CLAUDE.md")
  - $(Join-Path $Workspace "SyncSpace/主身想法.txt")
  - $(Join-Path $Workspace "SyncSpace/主分身沟通.txt")

日常使用:
  1. 往 SyncSpace/主身想法.txt 写你的想法和需求
  2. 查看 SyncSpace/主分身沟通.txt 了解分身进展并回复
  3. 你也可以往 SyncSpace/ 目录放任意文件（参考资料、表格等），分身启动时会读取

手动启动分身:
  bash ./runtime/$engine/$engine-docker run

重新运行本向导（补配引擎/密钥/定时任务）:
  .\runtime\shared\profile-init.ps1
"@
