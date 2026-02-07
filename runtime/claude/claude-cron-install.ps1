param(
  [ValidateRange(0,23)]
  [int]$Hour = 9
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$job = Join-Path $scriptDir "claude-cron-run"
$timeStr = "{0:D2}:00" -f $Hour

$action = New-ScheduledTaskAction -Execute "bash" -Argument "-lc '$job >> $scriptDir/claude-cron.log 2>&1'"
$trigger = New-ScheduledTaskTrigger -Daily -At $timeStr
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName "AI-Avatar-Claude-Cron" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
Write-Output "已安装定时任务: 每天 ${timeStr} 运行 claude-cron-run"
Write-Output "卸载命令: Unregister-ScheduledTask -TaskName 'AI-Avatar-Claude-Cron' -Confirm:`$false"
