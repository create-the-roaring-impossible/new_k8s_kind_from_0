<#
.SYNOPSIS
  This script backup a source path into a destination path.

.DESCRIPTION
  The script backup a source path into a destination path.

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
  Date: 23/02/2025
  Version: 1.1.0
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

######################################################################
### Get the "drive letter" of the source, and destination, volumes ###
######################################################################

# Check if the $sourceVolume is empty
if ([string]::IsNullOrEmpty($sourceVolume)) {
  throw "Source volume name is empty. The script will stop!!"
}
$sourceDriveLetter = Get-DriveLetterFromVolumeName -volumeName $sourceVolume
# Check if the $sourceDriveLetter is empty
if ([string]::IsNullOrEmpty($sourceDriveLetter)) {
  throw "Source drive letter is empty, it means source volume not found. The script will stop!!"
}

# Check if the $destinationVolume is empty
if ([string]::IsNullOrEmpty($destinationVolume)) {
  throw "Destination volume name is empty. The script will stop!!"
}
$destinationDriveLetter = Get-DriveLetterFromVolumeName -volumeName $destinationVolume
# Check if the $destinationDriveLetter is empty
if ([string]::IsNullOrEmpty($destinationDriveLetter)) {
  throw "Destination drive letter is empty, it means destination volume not found. The script will stop!!"
}

# Get the source, and destination, paths
$sourcePath = "$sourceDriveLetter\$sourcePath"
$destinationPath = "$destinationDriveLetter\$destinationPath"

# Get the current date and time, in the format "yyyy-mm-dd-hh-mm-ss"
$currentDate = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"

# Create the destination folder path
$destinationFolder = Join-Path -Path $destinationPath -ChildPath $currentDate

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
  New-Item -ItemType Directory -Path $destinationFolder
  # Check if the destination folder was created successfully
  if (-not (Test-Path -Path $destinationFolder)) {
    throw "Failed to create destination folder '$destinationFolder'. The script will stop!!"
  }
}

# Start the backup
Write-Output "Backup, from '$sourcePath' to '$destinationFolder', started!!"

try {
  # Copy the contents of the source disk to the destination folder
  Copy-Item -Path $sourcePath\* -Destination $destinationFolder -Recurse -Force -ErrorAction Stop
  # End the backup successfully
  Write-Output "Backup, from '$sourcePath' to '$destinationFolder', completed successfully!!"
} catch {
  throw "Failed to copy items from '$sourcePath' to '$destinationFolder'. Error: $_"
}