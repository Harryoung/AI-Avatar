#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "错误: $*" >&2
  exit 1
}

need_cmd() {
  local cmd="$1"
  local url="$2"
  command -v "${cmd}" >/dev/null 2>&1 || fail "未安装 ${cmd}。请前往 ${url} 下载安装后重试。"
}

need_cmd docker "https://docs.docker.com/get-started/get-docker/"
need_cmd git    "https://git-scm.com/downloads"

if ! docker compose version >/dev/null 2>&1; then
  fail "未检测到 docker compose。请前往 https://docs.docker.com/get-started/get-docker/ 升级 Docker Desktop 或安装 compose 插件。"
fi

echo "依赖检查通过: docker, docker compose, git"
