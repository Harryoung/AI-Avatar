#!/usr/bin/env bash
set -euo pipefail

workspace="${AVATAR_WORKSPACE_DIR:-./workspace}"
agents="${workspace}/AGENTS.md"
claude="${workspace}/CLAUDE.md"

[[ ! -f "${agents}" || ! -f "${claude}" ]] && exit 0

if ! cmp -s "${agents}" "${claude}"; then
  if [[ "${agents}" -nt "${claude}" ]]; then
    cp "${agents}" "${claude}"
  else
    cp "${claude}" "${agents}"
  fi
fi
