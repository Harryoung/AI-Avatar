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
  fi
  # timestamps equal but content differs: skip to avoid silent misoverwrite
fi
