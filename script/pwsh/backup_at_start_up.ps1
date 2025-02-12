<#
.SYNOPSIS
  This script backup a source path into a destination path.

.DESCRIPTION
  That script backup a source path into a destination path.

.PARAMETER [ParameterName]
  [ParameterDescription]
    [ParameterMandatory]
      sourcePath: The path of the source disk.
      destinationPath: The path of the destination folder.

.EXAMPLE
  .\backup_at_start_up.ps1 "D:\Personale\" "I:\"

.NOTES
    Author: Matteo Cristiano
    Date: 09/02/2025
    Version: 1.0.0
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$sourcePath,
    [Parameter(Mandatory=$true)]
    [string]$destinationPath
)

# Get the current date and time in the format yyyy-mm-dd-hh-mm-ss
$currentDate = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"

# Create the destination folder path
$destinationFolder = Join-Path -Path $destinationPath -ChildPath $currentDate

# Start the backup
Write-Output "Backup, from '$sourcePath' to '$destinationFolder', started!!"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
  New-Item -ItemType Directory -Path $destinationFolder
}

# Copy the contents of the source disk to the destination folder
Copy-Item -Path $sourcePath\* -Destination $destinationFolder -Recurse -Force

# End the backup
Write-Output "Backup, from '$sourcePath' to '$destinationFolder', completed successfully!!"