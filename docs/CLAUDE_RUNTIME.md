# CLAUDE Runtime

## 常用命令
- 构建：`./runtime/claude/claude-docker build`
- 运行：`./runtime/claude/claude-docker run`
- 进入 shell：`./runtime/claude/claude-docker shell`
- 设置 token：`./runtime/claude/claude-docker set-token`
- 设置 base url：`./runtime/claude/claude-docker set-base-url`

## 配置说明
- 默认挂载 `<repo>/workspace -> /workspace`
- 可覆盖：`AVATAR_WORKSPACE_DIR=/abs/path ./runtime/claude/claude-docker run`
- Claude 读取 `CLAUDE.md`，初始化脚本会自动生成。

## 定时任务
- macOS/Linux：`./runtime/claude/claude-cron-install`
- Windows：`./runtime/claude/claude-cron-install.ps1`
