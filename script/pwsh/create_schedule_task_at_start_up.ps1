<#
.SYNOPSIS
  This script create a Windows Schedule Task, at start up, to run a Powershell script.

.DESCRIPTION
  That script create a Windows Schedule Task, at start up, to run a Powershell script.

.PARAMETER [ParameterName]
  [ParameterDescription]
    [ParameterMandatory]
      taskName: The name of the Schedule Task to create.
      scriptToRun: The path of the script to run.

.EXAMPLE
  .\create_schedule_task_at_start_up.ps1 "BackupToExternalHDD" "E:\Repositories\GitHub\new_k8s_kind_from_0\script\pwsh\backup_at_start_up.ps1 'D:\Personale\' 'I:\'"

.NOTES
    Author: Matteo Cristiano
    Date: 09/02/2025
    Version: 1.0.0
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$taskName,
    [Parameter(Mandatory=$true)]
    [string]$scriptToRun
)

# Start creation
Write-Output "Schedule Task '$taskName' creation in progress.."

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $scriptToRun
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal

# End creation
Write-Output "Schedule Task '$taskName' creation completed successfully!!"