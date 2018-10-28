# ----------------------------------------------------
# Register-EventSource
# ----------------------------------------------------
function Register-ApplicationEventSource {
  [CmdletBinding(PositionalBinding = $false)]
  Param (
    [Parameter(Mandatory=$True,Position=0)]
    [string] $Source
  )
  if ((Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application -Name) -cnotcontains $Source) {
    New-EventLog -LogName Application -Source $Source
  }
}

# ----------------------------------------------------
# UnRegister-EventSource
# ----------------------------------------------------
function UnRegister-ApplicationEventSource {
  [CmdletBinding(PositionalBinding = $false)]
  Param (
    [Parameter(Mandatory=$True,Position=0)]
    [string] $Source
  )
  if ((Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application -Name) -ccontains $Source) {
    Remove-EventLog -Source $Source
  }
}

# ----------------------------------------------------
# Log-Event
# ----------------------------------------------------
function Log-Event {
  [CmdletBinding(PositionalBinding = $false)]
  Param (
    [Parameter(Mandatory=$True,Position=0)]
    [string] $EntryType,
    [Parameter(Mandatory=$True,Position=1)]
    [string] $Message
  )
  Write-EventLog -LogName 'Application' -Source 'ChefClientUpdater' -EventId 1 -EntryType $EntryType -Message $Message -Category 0
  Write-Host $Message
}

# ----------------------------------------------------
# Install-UpdaterScheduledTask
# ----------------------------------------------------
# function Install-UpdaterScheduledTask {
#   $updaterTask = Get-ScheduledTask -TaskName "ChefClientUpdater" -ErrorAction SilentlyContinue
#   if ( -Not $updaterTask ) {
#     Log-Event -EntryType Information -Message "Installing ChefClientUpdater Scheduled Task"
#     $taskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Seconds 60) -RandomDelay (New-TimeSpan -Seconds 30)
#     $taskAction  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Unrestricted -Command $PSCommandPath"
#     $scheduledTask = Register-ScheduledTask -Force -Trigger $taskTrigger -User 'NT AUTHORITY\SYSTEM' -TaskName 'ChefClientUpdater' -Action $taskAction
#     $scheduledTask.Enable
#   }
# }

# ----------------------------------------------------
# Stop-ChefClient
# ----------------------------------------------------
function Stop-ChefClient {
  # Stop any chef client services (which are in any case deprecated)
  foreach ($chefService in Get-Service -Name "chef client", "chef-client" -ErrorAction SilentlyContinue) {
    Log-Event -EntryType Information -Message "Service $($chefService.Name) is $($chefService.Status)"
    if ($chefService.Status -eq 'Running') {
      Log-Event -EntryType Information -Message "Stopping service $($chefService.Name)"
      $chefService.Stop()
    }
  } 
  # Stop any chef client scheduled tasks
  foreach ($chefTask in Get-ScheduledTask -TaskName "chef-client", "chef client" -ErrorAction SilentlyContinue) {
    if ($chefTask.State -eq 'Running') {
      Log-Event -EntryType Information -Message "Stopping sheduled task $($chefTask)"
      Stop-ScheduledTask $chefTask
    }
    if ($chefTask.State -eq 'Ready') {
      Log-Event -EntryType Information -Message "Disabling sheduled task $($chefTask)"
      Disable-ScheduledTask $chefTask
    }
  }
  # Kill process if it running by other means
  foreach ($chefProcess in Get-WmiObject win32_process -Filter "CommandLine like '%chef-client%' and Name = 'ruby.exe'") {
    Log-Event -EntryType Information -Message "killing chef-client process $($chefProcess.ProcessId) started by $($chefProcess.CommandLine)"
    $chefProcess.Terminate()
  }
}

function Start-ChefClient {
  Log-Event -EntryType Information -Message "Attempting to start periodic Chef Client"
  # Start any chef client services (which are in any case deprecated)
  foreach ($chefService in Get-Service -Name "chef client", "chef-client" -ErrorAction SilentlyContinue) {
    Log-Event -EntryType Information -Message "Service $($chefService.Name) is $($chefService.Status)"
    if ($chefService.Status -eq 'Stopped') {
      Log-Event -EntryType Information -Message "Starting service $($chefService.Name)"
      $chefService.Start()
    }
  } 
  # Start any chef client scheduled tasks
  foreach ($chefTask in Get-ScheduledTask -TaskName "chef-client", "chef client" -ErrorAction SilentlyContinue) {
    if ($chefTask.State -eq 'Disabled') {
      Log-Event -EntryType Information -Message "Enabling sheduled task $($chefTask)"
      Enable-ScheduledTask $chefTask
    }
  }
}

function UnInstall-ChefClient {
  Stop-ChefClient
  Unregister-ApplicationEventSource -Source 'chef-client'
  Unregister-ApplicationEventSource -Source 'ChefClient'
  Unregister-ApplicationEventSource -Source 'Chef Client'
  foreach ($package in (Get-Package -Name 'chef *' -ErrorAction 'SilentlyContinue')) {
    Log-Event -EntryType Warn -Message "Uninstalling package $($package.Name)"
    Uninstall-Package -Force -Confirm $package
  }
}

function Install-ChefClient {
  [CmdletBinding(PositionalBinding = $false)]
  Param (
    [Parameter(Mandatory=$True,Position=0)]
    [string] $MsiPath
  )
  Log-Event -EntryType Information -Message "Installing package $($MsiPath)"
  Install-Package $MsiPath
  Start-ChefClient
}

# ----------------------------------------------------
# Download-ChefClient
# ----------------------------------------------------
function Download-ChefClient {
  [CmdletBinding(PositionalBinding = $false)]
  Param (
    [Parameter(Mandatory=$True,Position=0)]
    [string] $Url,
    [Parameter(Mandatory=$True,Position=1)]
    [string] $Checksum
  )
  $chefPackageFilename = $Url.split('/')[-1]
  $chefPackageFullFilename = "c:\ChefClientUpdater\PackageCache\$($chefPackageFilename)"
  if (-Not (Test-Path -Path $chefPackageFullFilename)) {
    Log-Event -EntryType Information -Message "Downloading $($Url) to $($chefPackageFullFilename)"
    #$OldProgressPreference = $ProgressPreference
    #$ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile $chefPackageFullFilename -UseBasicParsing
    #$ProgressPreference = $OldProgressPreference
  }
  if ((Get-FileHash -Path $chefPackageFullFilename -Algorithm SHA256).Hash.ToLower() -eq $Checksum.ToLower()) {
    Log-Event -EntryType Information -Message "Checksum OK for $($chefPackageFullFilename)"
    UnInstall-ChefClient
    Install-ChefClient -MsiPath $chefPackageFullFilename        
  } else {
    Log-Event -EntryType Information -Message "Bad checksum for $($chefPackageFullFilename)... deleting"
    Remove-Item -Path $chefPackageFullFilename
  }
}

# ----------------------------------------------------
# Script Entry point is here folks
# ----------------------------------------------------

# Disable progress updates to make things a little faster
$OldProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
 
Register-ApplicationEventSource -Source 'ChefClientUpdater'
Log-Event -EntryType Information -Message "Starting Chef Client Updater"

# Install-UpdaterScheduledTask

$Config = Get-Content -Path 'c:\ChefClientUpdater\config.json' | ConvertFrom-Json
$chefPackage = Get-Package -Name 'Chef *' -ErrorAction SilentlyContinue

Log-Event -EntryType Information -Message "Chef Client versions: Current = '$($chefPackage.Version)'. Desired = $($Config.desired.package.version)"
if ( $Config.desired.package.version -ne $chefPackage.Version) {
  Download-ChefClient -Url $Config.desired.package.url -Checksum $Config.desired.package.checksum
}

Log-Event -EntryType Information -Message "Chef Client Updater run completed"
$ProgressPreference = $OldProgressPreference
