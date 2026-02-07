# QUICKSTART

## 第一次使用

1. 克隆项目：`git clone <仓库地址> && cd AI-Avatar`
2. 运行初始化向导：`./runtime/shared/profile-init.sh`（Windows：`.\runtime\shared\profile-init.ps1`）

向导包含以下步骤，跟着提示走即可：

1. 依赖检查（Docker / Git）
2. 设置工作目录
3. 填写个人画像
4. 选择 AI 引擎（Claude / Codex）
5. 配置 API 密钥
6. (可选) GitHub Token
7. (可选) 定时任务
8. 完成汇总

## 初始化会做什么
- 生成 `profile.local.yaml`
- 在你选择的 workspace 下生成：
  - `AGENTS.md` + `CLAUDE.md`（同内容，自动兼容双引擎）
  - `SyncSpace/主身想法.txt`
  - `SyncSpace/主分身沟通.txt`
  - `SyncSpace/沟通归档/`
- 构建 Docker 镜像
- 配置 API 密钥（写入 Docker volume）

## 高级用户：单独执行各步骤

如果不想走向导，可以分步手动操作：

```bash
# 依赖检查
./runtime/shared/bootstrap.sh

# 初始化画像和工作目录（只生成文件，不配置引擎）
# 直接编辑 profile.template.yaml → 另存为 profile.local.yaml

# 构建 Docker 镜像
./runtime/claude/claude-docker build    # 或 codex-docker

# 配置密钥
./runtime/claude/claude-docker set-token
./runtime/claude/claude-docker set-base-url      # 可选，中转/代理
./runtime/claude/claude-docker set-github-token   # 可选

# Codex 用设备登录
./runtime/codex/codex-docker login-device
./runtime/codex/codex-docker set-github-token     # 可选

# 安装定时任务（可指定小时，默认 9 点）
./runtime/claude/claude-cron-install 9
./runtime/codex/codex-cron-install 14

# 启动分身
./runtime/claude/claude-docker run
./runtime/codex/codex-docker run
```
