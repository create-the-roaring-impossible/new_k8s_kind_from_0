<#
.SYNOPSIS
  This script create a Windows Schedule Task, at start up, to run a Powershell script.

.DESCRIPTION
  The script create a Windows Schedule Task, at start up, to run a Powershell script.

.PARAMETER [ParameterName]
  [ParameterDescription]
    [ParameterMandatory]
      taskName: The name of the Schedule Task to create.
      cmdToRun: The path of the script to run.

.EXAMPLE
  .\create_schedule_task_at_start_up.ps1 "BackupToExternalHDD" "E:\Repositories\GitHub\new_k8s_kind_from_0\script\pwsh\backup_at_start_up.ps1 'HDD Archive' 'Personale\' 'SAMSUNG Archive' ''" # TODO: to test
  .\create_schedule_task_at_start_up.ps1 "BackupToGoogleDrive" "E:\Repositories\GitHub\new_k8s_kind_from_0\script\pwsh\backup_at_start_up.ps1 'HDD Archive' 'Personale\' 'Google Drive' 'Il mio Drive\'" # TODO: to test

.NOTES
  Author: Matteo Cristiano
  Date: 23/02/2025
  Version: 1.1.0
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$taskName,
    [Parameter(Mandatory=$true)]
    [string]$cmdToRun
)

# Check if the Schedule Task already exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
  Write-Output "Schedule Task '$taskName' already exists. The script will stop!!"
  exit
} else {
  # Create the Task Action, Trigger, Settings, and Principal, to use with the Scheduled Task
  $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $cmdToRun
  $trigger = New-ScheduledTaskTrigger -AtStartup
  $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden
  $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

  # Start creation
  Write-Output "Schedule Task '$taskName' creation in progress.."

  try {
    # Create the Scheduled Task
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal
    # End creation
    Write-Output "Schedule Task '$taskName' creation completed successfully!!"
  } catch {
    throw "Failed to create Schedule Task '$taskName'. Error: $_"
  }
}