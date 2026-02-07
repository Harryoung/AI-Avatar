# AI-Avatar

把 Claude Code 或 Codex 变成你的 AI 分身。

填一次个人画像，启动后就能自动帮你干活。你只需要往两个文件里写字，就能跟它协作。

## 你能得到什么

- 一个 24 小时待命的 AI 助手（你的"分身"）
- 只需要会打字，就能跟它协作
- 支持定时自动运行，不需要一直盯着
- 支持 Claude 和 Codex 两种 AI 引擎

## 你日常只需要做三件事

初始化完成后，你的工作区里会出现一个 `SyncSpace` 文件夹，里面有两个文件：

### 1. 写想法 → `SyncSpace/主身想法.txt`

想到什么就打开这个文件随便写。比如：

```
帮我整理一下本周的会议纪要
最近想学 Python，帮我找点入门资料
根据SyncSpace下关于我的资料，帮我搭建一个个人网站
```

分身每次启动时会读这个文件，然后去执行。

### 2. 看沟通 → `SyncSpace/主分身沟通.txt`

分身在干活过程中如果遇到需要你拿主意的事，会写在这里。你打开看到问题后，照着格式回复就行：

```
=== 分身 | 2026-02-04 14:30 ===
整理会议纪要时发现有两个版本，用哪个？
- 版本A：周一王总发的
- 版本B：周三李经理更新的

=== 主身 ===
用版本B。
```

就这么简单 —— 打开文件、在最下面写上 `=== 主身 ===`，换一行写你的回复，保存即可。

### 3. 放文件 → `SyncSpace/`

你可以往 `SyncSpace/` 目录放任意文件（参考资料、表格、图片等），分身启动时会读取这个目录，可以直接使用里面的内容。

## 安全须知：workspace 隔离

AI 分身运行在 Docker 容器中，**只能访问你指定的 workspace 目录**，无法触及电脑上的其他文件。

- 需要分身处理的文件（文档、表格、图片等），请先放到 workspace 下（推荐放 `SyncSpace/`）
- 分身生成的所有产出也会保存在 workspace 内
- 你不用担心分身会在电脑的其他位置读写或搞破坏

## 3 分钟上手

1. 克隆项目：`git clone <仓库地址> && cd AI-Avatar`
2. 运行初始化向导：`./runtime/shared/profile-init.sh`

向导会自动引导你完成依赖检查、画像填写、引擎选择、密钥配置、定时任务安装等全部步骤。

Windows 用户请运行 PowerShell 版：`.\runtime\shared\profile-init.ps1`

> 注意，作者手头没有Windows电脑，因此不保证没有坑，见谅

## 更多文档

- 快速开始：`docs/QUICKSTART.md`
- Claude 运行：`docs/CLAUDE_RUNTIME.md`
- Codex 运行：`docs/CODEX_RUNTIME.md`
- 画像填写：`docs/PROFILE_GUIDE.md`
- Windows：`docs/WINDOWS.md`
- 故障排查：`docs/TROUBLESHOOTING.md`
