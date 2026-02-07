FROM node:20-bookworm-slim

ARG CLAUDE_NPM_PKG=@anthropic-ai/claude-code
ARG CLAUDE_NPM_VERSION=latest

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    git \
    tini \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g "${CLAUDE_NPM_PKG}@${CLAUDE_NPM_VERSION}" \
  && npm cache clean --force

ENV HOME=/home/claude
RUN mkdir -p "${HOME}/.config/claude" "${HOME}/.config/git" \
  && chmod 0777 "${HOME}" "${HOME}/.config" "${HOME}/.config/claude" "${HOME}/.config/git"

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]
CMD ["claude"]
