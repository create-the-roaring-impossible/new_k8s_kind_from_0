<#
.SYNOPSIS
  This script backup a source path into a destination path.

.DESCRIPTION
  That script backup a source path into a destination path.

.PARAMETER [ParameterName]
  [ParameterDescription]
    [ParameterMandatory]
      sourceVolume: The name of the source volume.
      sourcePath: The path of the source files, to copy.
      destinationVolume: The name of the destination volume.
      destinationPath: The path of the destination files, to copy.

.EXAMPLE
  .\backup_at_start_up.ps1 "HDD Archive" "Personale\" "SAMSUNG Archive" ""
  .\backup_at_start_up.ps1 "HDD Archive" "Personale\" "Google Drive" "Il mio Drive\"

.NOTES
    Author: Matteo Cristiano
    Date: 16/02/2025
    Version: 1.0.1
#>

param (
  [Parameter(Mandatory=$true)]
  [string]$sourceVolume,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [string]$sourcePath,
  [Parameter(Mandatory=$true)]
  [string]$destinationVolume,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [string]$destinationPath
)

# Function to get the "drive letter" of a volume, from the "volume name"
function Get-DriveLetterFromVolumeName {
  param (
    [Parameter(Mandatory=$true)]
    [string]$volumeName
  )

  $volumes = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='$volumeName'"

  if ($volumes.Count -eq 0) {
    throw "Volume with name '$volumeName' not found!!"
  }

  return $volumes.DriveLetter
}

# Get the "drive letter" of the source, and destination, volumes
$sourceDriveLetter = Get-DriveLetterFromVolumeName -volumeName $sourceVolume
$destinationDriveLetter = Get-DriveLetterFromVolumeName -volumeName $destinationVolume

# Get the source, and destination, paths
$sourcePath = "$sourceDriveLetter\$sourcePath"
$destinationPath = "$destinationDriveLetter\$destinationPath"

# Get the current date and time, in the format "yyyy-mm-dd-hh-mm-ss"
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