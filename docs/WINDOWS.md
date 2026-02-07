# WINDOWS

> 当前为实验支持，尚未完整测试。

## 推荐路径
1. 安装 Docker Desktop（启用 WSL2）。
2. 使用 PowerShell 执行：
   - `./runtime/shared/bootstrap.ps1`
   - `./runtime/shared/profile-init.ps1`
3. 安装计划任务（可选）：
   - Claude: `./runtime/claude/claude-cron-install.ps1`
   - Codex: `./runtime/codex/codex-cron-install.ps1`

## 已知问题
- 路径分隔符与卷挂载行为差异。
- TTY 交互行为与 Unix 不一致。
- 计划任务权限与触发器存在差异。
- 代理环境变量继承不稳定。
