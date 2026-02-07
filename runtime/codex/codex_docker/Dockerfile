FROM node:20-bookworm-slim

ARG CODEX_NPM_PKG=@openai/codex
ARG CODEX_NPM_VERSION=latest

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    git \
    tini \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g "${CODEX_NPM_PKG}@${CODEX_NPM_VERSION}" \
  && npm cache clean --force

ENV HOME=/home/codex
RUN mkdir -p "${HOME}" "${HOME}/.config" "${HOME}/.codex" "${HOME}/.config/git" \
  && chmod 0777 "${HOME}" "${HOME}/.config" "${HOME}/.codex" "${HOME}/.config/git"

WORKDIR /workspace
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["codex"]
