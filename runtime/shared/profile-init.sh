#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
out_file="${root_dir}/profile.local.yaml"
template_file="${root_dir}/profile.template.yaml"
agents_template="${root_dir}/AGENTS.template.md"
default_workspace="${root_dir}/workspace"
workspace_dir=""

# --- helpers ---

banner() {
  echo ""
  echo "========================================"
  echo "  $1"
  echo "========================================"
  echo ""
}

info()  { echo "[INFO] $*"; }
ask()   { read -r -p "$1" "$2"; }

detect_lang() {
  local l="${LANG:-${LC_ALL:-zh-CN}}"
  case "${l}" in
    zh*) echo "zh-CN" ;;
    en*) echo "en-US" ;;
    ja*) echo "ja-JP" ;;
    ko*) echo "ko-KR" ;;
    *)   echo "zh-CN" ;;
  esac
}

detect_tz() {
  if [[ -f /etc/timezone ]]; then
    cat /etc/timezone
  elif [[ -L /etc/localtime ]]; then
    readlink /etc/localtime | sed 's|.*/zoneinfo/||'
  elif command -v timedatectl >/dev/null 2>&1; then
    timedatectl show -p Timezone --value 2>/dev/null || echo "Asia/Shanghai"
  else
    echo "Asia/Shanghai"
  fi
}

sync_agent_files() {
  local ws="$1"
  local agents_file="${ws}/AGENTS.md"
  local claude_file="${ws}/CLAUDE.md"

  if [[ ! -f "${agents_file}" && ! -f "${claude_file}" ]]; then
    cp "${agents_template}" "${agents_file}"
    cp "${agents_file}" "${claude_file}"
    info "已创建 ${agents_file} 与 ${claude_file}"
    return
  fi

  if [[ -f "${agents_file}" && ! -f "${claude_file}" ]]; then
    cp "${agents_file}" "${claude_file}"
    info "已从 AGENTS.md 同步 CLAUDE.md"
    return
  fi

  if [[ -f "${claude_file}" && ! -f "${agents_file}" ]]; then
    cp "${claude_file}" "${agents_file}"
    info "已从 CLAUDE.md 同步 AGENTS.md"
    return
  fi

  if ! cmp -s "${agents_file}" "${claude_file}"; then
    if [[ "${agents_file}" -nt "${claude_file}" ]]; then
      cp "${agents_file}" "${claude_file}"
      info "检测到差异，已以 AGENTS.md 覆盖 CLAUDE.md"
    else
      cp "${claude_file}" "${agents_file}"
      info "检测到差异，已以 CLAUDE.md 覆盖 AGENTS.md"
    fi
  fi
}

fill_agents_field() {
  local file="$1"
  local field="$2"
  local value="$3"
  [[ -z "${value}" ]] && return
  sed -i.bak "s|^\(\\*\\*${field}\\*\\*：\)$|\1${value}|" "${file}"
  rm -f "${file}.bak"
}

# ============================================================
# Step 0: 欢迎
# ============================================================

banner "AI-Avatar 初始化向导"
cat <<'WELCOME'
欢迎使用 AI-Avatar！本向导将引导你完成所有配置：

  1. 检查依赖（Docker / Git）
  2. 设置工作目录
  3. 填写个人画像
  4. 选择 AI 引擎（Claude / Codex）
  5. 配置 API 密钥
  6. (可选) 配置 GitHub Token
  7. (可选) 安装定时任务
  8. (可选) 自动更新
  9. 完成！

WELCOME

# ============================================================
# Step 1: 依赖检查
# ============================================================

banner "Step 1/9: 依赖检查"
bash "${root_dir}/runtime/shared/bootstrap.sh"

# ============================================================
# Step 2: workspace 路径
# ============================================================

banner "Step 2/9: 设置工作目录"
echo "AI 分身运行在 Docker 容器中，只能访问这个目录下的文件。"
echo "需要分身处理的文件请放到此目录下，分身也不会触及目录外的任何文件。"
echo ""
ask "workspace 路径 (回车使用默认: ${default_workspace}): " workspace_dir
workspace_dir="${workspace_dir:-${default_workspace}}"

mkdir -p "${workspace_dir}/SyncSpace/沟通归档"
touch "${workspace_dir}/SyncSpace/主身想法.txt"
touch "${workspace_dir}/SyncSpace/主分身沟通.txt"
sync_agent_files "${workspace_dir}"
info "工作目录已就绪: ${workspace_dir}"

# ============================================================
# Step 3: 个人画像
# ============================================================

profile_existed=false
if [[ -f "${out_file}" ]]; then
  profile_existed=true
fi

if [[ "${profile_existed}" == "true" ]]; then
  banner "Step 3/9: 个人画像（已有配置，跳过）"
  info "检测到 ${out_file} 已存在，跳过画像填写。"
else
  banner "Step 3/9: 个人画像"

  # 3a: 基本画像 → profile.local.yaml
  echo "--- 基本信息（写入 profile.local.yaml）---"
  ask "昵称 (默认: Your Alias): " p_name
  ask "角色/职位 (默认: Your Role): " p_role
  p_name="${p_name:-Your Alias}"
  p_role="${p_role:-Your Role}"

  auto_lang="$(detect_lang)"
  auto_tz="$(detect_tz)"
  info "自动检测 → 语言: ${auto_lang}，时区: ${auto_tz}"

  cat >"${out_file}" <<YAML
profile:
  name: "${p_name}"
  language: "${auto_lang}"
  timezone: "${auto_tz}"

work:
  role: "${p_role}"
  goals:
    - "Goal A"
    - "Goal B"

preferences:
  communication_style: "direct"
  output_length: "short"
YAML
  info "已生成 ${out_file}"
  info "可参考模板自行补充更多字段: ${template_file}"

  # 3b: 身份概览 → AGENTS.md（全部可跳过）
  echo ""
  echo "--- 身份概览（写入 AGENTS.md，全部可跳过，直接回车跳过）---"
  ask "姓名: " id_name
  ask "性别: " id_gender
  ask "家乡: " id_hometown
  ask "现居: " id_location
  ask "职业: " id_career
  ask "公司: " id_company
  ask "人格(如 INTJ): " id_personality

  agents_file="${workspace_dir}/AGENTS.md"
  if [[ -f "${agents_file}" ]]; then
    fill_agents_field "${agents_file}" "姓名" "${id_name}"
    fill_agents_field "${agents_file}" "性别" "${id_gender}"
    fill_agents_field "${agents_file}" "家乡" "${id_hometown}"
    fill_agents_field "${agents_file}" "现居" "${id_location}"
    fill_agents_field "${agents_file}" "职业" "${id_career}"
    fill_agents_field "${agents_file}" "公司" "${id_company}"
    fill_agents_field "${agents_file}" "人格" "${id_personality}"
    # Remove the placeholder hint line if any field was filled
    if [[ -n "${id_name}${id_gender}${id_hometown}${id_location}${id_career}${id_company}${id_personality}" ]]; then
      sed -i.bak '/^> 请用户补充个人实际信息后删除本行。/d' "${agents_file}"
      rm -f "${agents_file}.bak"
    fi
    # Sync back
    cp "${agents_file}" "${workspace_dir}/CLAUDE.md"
    info "已更新 AGENTS.md 身份概览"
  fi
fi

# ============================================================
# Step 4: 选择引擎
# ============================================================

banner "Step 4/9: 选择 AI 引擎"
echo "  1) Claude  (Anthropic)"
echo "  2) Codex   (OpenAI)"
echo ""
ask "输入序号 (默认: 1): " engine_choice
engine_choice="${engine_choice:-1}"

case "${engine_choice}" in
  2) engine="codex" ;;
  *) engine="claude" ;;
esac
info "已选择引擎: ${engine}"

# ============================================================
# Step 5: 构建 Docker + 配置密钥
# ============================================================

banner "Step 5/9: 配置密钥"

docker_script="${root_dir}/runtime/${engine}/${engine}-docker"
export AVATAR_WORKSPACE_DIR="${workspace_dir}"

echo "正在构建 Docker 镜像（首次较慢）..."
"${docker_script}" build

if [[ "${engine}" == "claude" ]]; then
  echo ""
  echo "获取 Anthropic API Key 的步骤："
  echo "  1. 打开 https://console.anthropic.com/"
  echo "  2. 注册/登录 → 进入 Settings → API Keys"
  echo "  3. 创建一个新的 Key，复制下来"
  echo ""
  ask "是否现在配置 API Key？(Y/n): " do_token
  do_token="${do_token:-Y}"
  if [[ "${do_token}" =~ ^[Yy] ]]; then
    "${docker_script}" set-token
  else
    info "跳过。后续可运行: ${docker_script} set-token"
  fi

  echo ""
  ask "是否需要配置自定义 Base URL（中转/代理）？(y/N): " do_base
  do_base="${do_base:-N}"
  if [[ "${do_base}" =~ ^[Yy] ]]; then
    "${docker_script}" set-base-url
  fi
else
  echo ""
  echo "Codex 使用设备认证流程："
  echo "  运行后会给出一个 URL 和验证码"
  echo "  在浏览器中打开该 URL 并输入验证码即可"
  echo ""
  ask "是否现在进行设备登录？(Y/n): " do_login
  do_login="${do_login:-Y}"
  if [[ "${do_login}" =~ ^[Yy] ]]; then
    "${docker_script}" login-device
  else
    info "跳过。后续可运行: ${docker_script} login-device"
  fi
fi

# ============================================================
# Step 6: GitHub Token (可选)
# ============================================================

banner "Step 6/9: GitHub Token（可选）"
echo "如果你希望分身能访问你的 GitHub 仓库（读写代码、管理 Issue 等），"
echo "需要配置 GitHub Personal Access Token。"
echo "不需要可直接跳过。"
echo ""
ask "是否现在配置 GitHub Token？(y/N): " do_gh
do_gh="${do_gh:-N}"
if [[ "${do_gh}" =~ ^[Yy] ]]; then
  "${docker_script}" set-github-token
fi

# ============================================================
# Step 7: 定时任务 (可选)
# ============================================================

banner "Step 7/9: 定时任务（可选）"
echo "安装定时任务后，分身会每天自动启动一次。"
echo ""
ask "是否安装定时任务？(y/N): " do_cron
do_cron="${do_cron:-N}"
if [[ "${do_cron}" =~ ^[Yy] ]]; then
  ask "每天几点运行？(0-23，默认 9): " cron_hour
  cron_hour="${cron_hour:-9}"
  "${root_dir}/runtime/${engine}/${engine}-cron-install" "${cron_hour}"
fi

# ============================================================
# Step 8: 自动更新 (可选)
# ============================================================

banner "Step 8/9: 自动更新（可选）"
echo "安装自动更新后，Docker 镜像将定期重建以获取最新版本的 AI 引擎。"
echo ""
ask "是否安装自动更新？(y/N): " do_update
do_update="${do_update:-N}"
if [[ "${do_update}" =~ ^[Yy] ]]; then
  echo "  1) 每天"
  echo "  2) 每周（默认）"
  echo "  3) 每月"
  echo ""
  ask "更新频率 (1/2/3，默认 2): " update_freq_choice
  update_freq_choice="${update_freq_choice:-2}"
  case "${update_freq_choice}" in
    1) update_freq="daily" ;;
    3) update_freq="monthly" ;;
    *) update_freq="weekly" ;;
  esac
  ask "更新时间（0-23 点，默认 3）: " update_hour
  update_hour="${update_hour:-3}"
  "${root_dir}/runtime/${engine}/${engine}-update-cron-install" "${update_freq}" "${update_hour}"
fi

# ============================================================
# Step 9: 完成汇总
# ============================================================

banner "Step 9/9: 初始化完成！"

cat <<SUMMARY
已生成 / 更新的文件:
  - ${out_file}
  - ${workspace_dir}/AGENTS.md
  - ${workspace_dir}/CLAUDE.md
  - ${workspace_dir}/SyncSpace/主身想法.txt
  - ${workspace_dir}/SyncSpace/主分身沟通.txt

日常使用:
  1. 往 SyncSpace/主身想法.txt 写你的想法和需求
  2. 查看 SyncSpace/主分身沟通.txt 了解分身进展并回复
  3. 你也可以往 SyncSpace/ 目录放任意文件（参考资料、表格等），分身启动时会读取

手动启动分身:
  ./runtime/${engine}/${engine}-docker run

手动更新引擎:
  ./runtime/${engine}/${engine}-docker update

重新运行本向导（补配引擎/密钥/定时任务/自动更新）:
  ./runtime/shared/profile-init.sh
SUMMARY
