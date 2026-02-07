# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI-Avatar turns Claude Code or Codex into a personal AI assistant ("分身"). Users fill out a profile once, then interact asynchronously via text files in `SyncSpace/`. The system runs inside Docker containers with workspace-only access.

## Architecture

```
runtime/
  shared/           # Cross-engine: bootstrap.sh (dep check), profile-init.sh (9-step wizard)
  claude/            # Claude engine: claude-docker (compose wrapper), cron/update scripts, Dockerfile
  codex/             # Codex engine: codex-docker (compose wrapper), cron/update scripts, Dockerfile
workspace/           # Docker mount point — user's working directory
  SyncSpace/         # Async interaction: 主身想法.txt (user requests), 主分身沟通.txt (Q&A)
  CLAUDE.md          # Identity profile read by Claude engine
  AGENTS.md          # Identity profile read by Codex engine
profile.template.yaml  # Profile template (profile.local.yaml is gitignored)
AGENTS.template.md     # Identity profile template
memory/templates/      # Knowledge base templates (daily review, weekly plan, decision log)
```

**Dual-engine design**: Claude reads `workspace/CLAUDE.md`, Codex reads `workspace/AGENTS.md`. The init wizard keeps both files in sync.

**Docker isolation**: Containers mount only the workspace directory. API keys are stored in Docker volumes, not in the image. User UID/GID mapping ensures correct file permissions.

## Common Commands

```bash
# Initialize (interactive wizard — handles everything)
./runtime/shared/profile-init.sh

# Claude engine
./runtime/claude/claude-docker build             # Build Docker image
./runtime/claude/claude-docker run               # Run the avatar
./runtime/claude/claude-docker run -p "prompt"   # Run with specific prompt
./runtime/claude/claude-docker shell             # Enter container shell
./runtime/claude/claude-docker set-token         # Set Anthropic API key
./runtime/claude/claude-docker set-base-url      # Set API proxy URL
./runtime/claude/claude-docker set-github-token  # Set GitHub token
./runtime/claude/claude-docker update            # Update to latest version

# Codex engine (same pattern)
./runtime/codex/codex-docker build
./runtime/codex/codex-docker run
./runtime/codex/codex-docker update              # Update to latest version
./runtime/codex/codex-docker login-device        # Device auth flow
./runtime/codex/codex-docker status

# Cron (arg = hour, default 9)
./runtime/claude/claude-cron-install 9
./runtime/codex/codex-cron-install 14

# Auto-update (args = frequency hour, default weekly 3)
./runtime/claude/claude-update-cron-install weekly 3
./runtime/codex/codex-update-cron-install daily 4
```

## Key Environment Variables

- `AVATAR_WORKSPACE_DIR` — absolute path to workspace (default: `./workspace`)
- `HOST_UID` / `HOST_GID` — container user mapping (auto-detected)
- `CLAUDE_NPM_VERSION` — pin `@anthropic-ai/claude-code` version
- `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` — proxy passthrough

## CI/CD

Two GitHub Actions workflows run on PRs and pushes to `main`:

- **shellcheck** — lints all shell scripts under `runtime/`. SC2016 is intentionally suppressed for single-quoted container commands.
- **privacy-check** — uses ripgrep to block commits containing PII patterns (ID numbers, addresses, phone numbers, emails, AWS keys, GitHub tokens). Excludes `.git` and `secrets/.gitkeep`.

## Shell Script Conventions

- All scripts use `set -euo pipefail`
- Error messages are in Chinese (user-facing project)
- `claude-docker` and `codex-docker` are extensionless bash scripts (not `*.sh`)
- Docker Compose is wrapped via `dc()` helper function
- Preflight checks validate Docker, Compose, and workspace existence before any operation

## Privacy Rules

Files that must stay local (gitignored): `profile.local.yaml`, `secrets/*`, `*.log`, `.runtime/`

Never commit real personal data. Only commit templates. The privacy-check CI will block violations.
