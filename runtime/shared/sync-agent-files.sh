#!/usr/bin/env bash
set -euo pipefail

workspace="${AVATAR_WORKSPACE_DIR:-./workspace}"
agents="${workspace}/AGENTS.md"
claude="${workspace}/CLAUDE.md"

[[ ! -f "${agents}" || ! -f "${claude}" ]] && exit 0

if ! cmp -s "${agents}" "${claude}"; then
  if [[ "${agents}" -nt "${claude}" ]]; then
    cp "${agents}" "${claude}"
  elif [[ "${claude}" -nt "${agents}" ]]; then
    cp "${claude}" "${agents}"
  else
    echo "[warn] AGENTS.md and CLAUDE.md differ but have same timestamp; defaulting AGENTS.md → CLAUDE.md" >&2
    cp "${agents}" "${claude}"
  fi
fi
