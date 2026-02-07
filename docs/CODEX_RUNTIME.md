# CODEX Runtime

## 常用命令
- 构建：`./runtime/codex/codex-docker build`
- 运行：`./runtime/codex/codex-docker run`
- 进入 shell：`./runtime/codex/codex-docker shell`
- 设备登录：`./runtime/codex/codex-docker login-device`
- 登录状态：`./runtime/codex/codex-docker status`

## 配置说明
- 默认挂载 `<repo>/workspace -> /workspace`
- 可覆盖：`AVATAR_WORKSPACE_DIR=/abs/path ./runtime/codex/codex-docker run`
- Codex 读取 `AGENTS.md`，初始化脚本会自动生成。

## 定时任务
- macOS/Linux：`./runtime/codex/codex-cron-install`
- Windows：`./runtime/codex/codex-cron-install.ps1`
