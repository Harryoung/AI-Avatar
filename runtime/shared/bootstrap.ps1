$ErrorActionPreference = "Stop"

function Fail($Message) {
  Write-Error $Message
  exit 1
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Fail "未安装 docker。请前往 https://docs.docker.com/get-started/get-docker/ 下载安装 Docker Desktop。"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Fail "未安装 git。请前往 https://git-scm.com/downloads 下载安装 Git for Windows。"
}

try {
  docker compose version | Out-Null
} catch {
  Fail "未检测到 docker compose。请前往 https://docs.docker.com/get-started/get-docker/ 升级 Docker Desktop。"
}

Write-Output "依赖检查通过: docker, docker compose, git"
