#!/usr/bin/env bash
set -euo pipefail

export HOME="${HOME:-/home/claude}"
cfg_dir="${HOME}/.config/claude"

read_if_present() {
  local var_name="$1"
  local file_name="$2"
  local file_path="${cfg_dir}/${file_name}"
  if [[ -f "${file_path}" ]]; then
    local val
    val="$(<"${file_path}")"
    export "${var_name}=${val}"
  fi
}

if [[ "${CLAUDE_PREFER_ENV:-0}" != "1" ]]; then
  read_if_present ANTHROPIC_BASE_URL anthropic_base_url
  read_if_present ANTHROPIC_AUTH_TOKEN anthropic_auth_token
fi

exec "$@"
