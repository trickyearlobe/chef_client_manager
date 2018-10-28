# ----------------------------------------------------
# Install-UpdaterScheduledTask
# ----------------------------------------------------
$updaterTask = Get-ScheduledTask -TaskName "ChefClientUpdater" -ErrorAction SilentlyContinue
if ( -Not $updaterTask ) {
  $taskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(10) -RepetitionInterval (New-TimeSpan -Seconds 900) -RandomDelay (New-TimeSpan -Seconds 180)
  $taskAction  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Unrestricted -Command c:\ChefClientUpdater\ChefClientUpdater.ps1"
  $scheduledTask = Register-ScheduledTask -Force -Trigger $taskTrigger -User 'NT AUTHORITY\SYSTEM' -TaskName 'ChefClientUpdater' -Action $taskAction
  $scheduledTask.Enable
}
