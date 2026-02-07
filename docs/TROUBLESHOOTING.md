# TROUBLESHOOTING

## `docker: command not found`
先运行 `./runtime/shared/bootstrap.sh`，按提示安装 Docker Desktop。

## `docker compose` 不可用
升级 Docker Desktop，确保 Compose 插件可用。

## 工作目录不存在
报错中会显示路径，先执行：`mkdir -p <你的workspace路径>`。

## AGENTS.md / CLAUDE.md 内容不一致
重新运行：`./runtime/shared/profile-init.sh --workspace <你的workspace路径>`，脚本会按最新文件自动同步。

## cron 未触发
运行 `crontab -l` 确认条目安装成功，再检查对应 `*-cron.log`。
