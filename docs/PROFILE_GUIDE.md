# PROFILE GUIDE

## 初始化命令
- macOS/Linux: `./runtime/shared/profile-init.sh`
- Windows: `./runtime/shared/profile-init.ps1`

## 初始化结果
- 生成 `profile.local.yaml`（你的个人运行画像）
- 在你选择的 workspace 下生成：
  - `AGENTS.md`
  - `CLAUDE.md`
  - `SyncSpace/主身想法.txt`
  - `SyncSpace/主分身沟通.txt`
  - `SyncSpace/沟通归档/`

## 字段建议
- `profile.name`: 建议使用昵称或代号。
- `work.role`: 你的当前角色。
- `work.goals`: 2-3 条本周可执行目标。
- `preferences`: 你的沟通偏好。

## 双引擎兼容说明
- Codex 读取 `AGENTS.md`。
- Claude 读取 `CLAUDE.md`。
- 初始化脚本会自动保持两者一致。
