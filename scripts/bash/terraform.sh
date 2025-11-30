#!/bin/bash
set -e

# DESCRIPTION: The script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.
#              It will be used GitLab, to store the Terraform state remotely.
#
# REQUIREMENTS:
# - The path to the Terraform scripts (PATH)
# - The environment to set (ENV)
# - The scope to set (SCOPE)
# - The action to perform (ACTION) ['plan', 'apply', 'state move', 'state list', 'state remove', 'import']
# - The log level to set (LOG_LEVEL) [INFO, WARN, ERROR, DEBUG, TRACE]
# - The directory to use for the Terraform plugin cache (PLUGIN_CACHE_DIR) [optional]
# - Whether the plugin cache may break the dependency lock file (PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE) [optional]
# - The targets to use for the plan action (TARGETS) [optional]
# - The address of the resource to import, remove or move (ADDRESS) [optional]
# - The ID of the resource to import (ID) [optional]
# - The source address of the resource to move (SOURCE) [optional]
# - The destination address of the resource to move (DESTINATION) [optional]
# - The GitLab user to use for authentication (GITLAB_USER)
# - The GitLab token to use for authentication (GITLAB_TOKEN)
#
# USAGE: bash terraform.sh -PATH $PATH -ENV $ENV -SCOPE $SCOPE -ACTION $ACTION [-LOG_LEVEL $LOG_LEVEL] [-PLUGIN_CACHE_DIR $PLUGIN_CACHE_DIR] [-PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE <true|false>] [-TARGETS $TARGETS] [-SOURCE $SOURCE] [-DESTINATION $DESTINATION] [-ADDRESS $ADDRESS] [-ID $ID] -GITLAB_USER $USER -GITLAB_TOKEN $TOKEN
#
# EXAMPLE: bash terraform.sh 'terraform/local' 'local' 'desktop-s8glse7' 'plan' 'ERROR' '-target=aws_instance.instance_name,-target=aws_s3_bucket.bucket_name' 'gitlab_user' 'gitlab_token'
#          This example runs the 'plan' action, with the specified targets.
#
# NOTES: Ensure you have the necessary permissions to execute this script.
#        Make sure all required dependencies are installed:
#          - Terraform CLI installed
#          - GitLab access token with api permissions
#          - valid GitLab project path
#
# AUTHORS: Matteo Cristiano <slb6113@gmail.com>
#
# VERSION: 1.3.0
#
# DATE: 30/11/2025

############################
########## Inputs ##########
############################

while [[ $# -gt 0 ]]; do
  case $1 in
    -PATH)
      PATH="$2"
      shift 2
      ;;
    -ENV)
      ENV="$2"
      shift 2
      ;;
    -SCOPE)
      SCOPE="$2"
      shift 2
      ;;
    -ACTION)
      ACTION="$2"
      shift 2
      ;;
    -LOG_LEVEL)
      LOG_LEVEL="$2"
      shift 2
      ;;
    -PLUGIN_CACHE_DIR)
      PLUGIN_CACHE_DIR="$2"
      shift 2
      ;;
    -PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE)
      PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE="$2"
      shift 2
      ;;
    -TARGETS)
      TARGETS="$2"
      shift 2
      ;;
    -SOURCE)
      SOURCE="$2"
      shift 2
      ;;
    -DESTINATION)
      DESTINATION="$2"
      shift 2
      ;;
    -ADDRESS)
      ADDRESS="$2"
      shift 2
      ;;
    -ID)
      ID="$2"
      shift 2
      ;;
    -GITLAB_USER)
      GITLAB_USER="$2"
      shift 2
      ;;
    -GITLAB_TOKEN)
      GITLAB_TOKEN="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$PATH" || -z "$ENV" || -z "$SCOPE" || -z "$ACTION" || -z "$GITLAB_USER" || -z "$GITLAB_TOKEN" ]]; then
  echo "ERROR: Missing required parameters"
  echo "Required: -PATH, -ENV, -SCOPE, -ACTION, -GITLAB_USER, -GITLAB_TOKEN"
  echo "USAGE: bash terraform.sh -PATH <path> -ENV <env> -SCOPE <scope> -ACTION <action> -GITLAB_USER <user> -GITLAB_TOKEN <token> [OPTIONS]"
  echo "Optional: -LOG_LEVEL <level> -PLUGIN_CACHE_DIR <dir> -PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE <true|false> -TARGETS <targets> -SOURCE <source> -DESTINATION <destination> -ADDRESS <address> -ID <id>"
  exit 1
fi

# Validate LOG_LEVEL parameter
valid_actions=("plan" "apply" "state list" "state move" "state remove" "import")
if [[ ! " ${valid_actions[@]} " =~ " ${ACTION} " ]]; then
  echo "ERROR: Invalid action specified. Valid actions are: 'plan', 'apply', 'import', 'state list', 'state remove', and 'state move'"
  exit 1
fi

# Validate ACTION parameter
valid_actions=("plan" "apply" "state list" "state move" "state remove" "import")
if [[ ! " ${valid_actions[@]} " =~ " ${ACTION} " ]]; then
  echo "ERROR: Invalid action specified. Valid actions are: 'plan', 'apply', 'import', 'state list', 'state remove', and 'state move'"
  exit 1
fi

#   [Parameter(Mandatory=$true)]
#   [string]$Path,
#   [Parameter(Mandatory=$true)]
#   [string]$Env,
#   [Parameter(Mandatory=$true)]
#   [string]$Scope,
#   [Parameter(Mandatory=$true)]
#   [ValidateSet()]
#   [string]$Action,
#   [Parameter(Mandatory=$false)]
#   [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG', 'TRACE')]
#   [string]$LogLevel,
#   [Parameter(Mandatory=$false)]
#   [string]$PluginCacheDir,
#   [Parameter(Mandatory=$false)]
#   [ValidateSet('true', 'false')]
#   [string]$PluginCacheMayBreakDependencyLockFile,
#   [Parameter(Mandatory=$false)]
#   [string]$Targets,
#   [Parameter(Mandatory=$false)]
#   [string]$Address,
#   [Parameter(Mandatory=$false)]
#   [string]$Id,
#   [Parameter(Mandatory=$false)]
#   [string]$Source,
#   [Parameter(Mandatory=$false)]
#   [string]$Destination,
#   [Parameter(Mandatory=$true)]
#   [string]$GitLabUser,
#   [Parameter(Mandatory=$true)]
#   [string]$GitLabToken

###########################
######## Functions ########
###########################

# # Functions
# function Test-ExitCode {
#   <#
#   .SYNOPSIS
#     This function checks the last exit code and exits the script if it is not zero.

#   .DESCRIPTION
#     This function checks the last exit code and exits the script if it is not zero. It also outputs a custom error message.

#   .PARAMETER Message
#     The error message to output if the last exit code is not zero. (Mandatory)

#   .USAGE
#     Test-ExitCode -Message "Custom error message"

#   .EXAMPLE
#     Test-ExitCode -Message "ERROR: Terraform Listing failed."
#     This example checks the last exit code and outputs "ERROR: Terraform Listing failed." if it is not zero.
#   #>

#   param (
#     [Parameter(Mandatory=$true)]
#     [string]$Message
#   )

#   if ($LASTEXITCODE -ne 0) {
#     Write-Output ${Message}
#     exit 1
#   }
# }

echo "TEST"

# # Copy backend.tf and variables.tf, from $Path to $Path/$Env
# Copy-Item -Path "$Path/backend.tf" -Destination "$Path/$Env/backend.tf"
# Copy-Item -Path "$Path/variables.tf" -Destination "$Path/$Env/variables.tf"

# # Change directory to $Path/$Env
# Set-Location -Path "$Path/$Env"

# # Set TF_LOG environment variable, default to INFO if LogLevel is not provided
# if ([string]::IsNullOrWhiteSpace($LogLevel)) {
#   $env:TF_LOG = 'ERROR'
# } else {
#   $env:TF_LOG = $LogLevel
# }

# # Set TF_LOG_PATH environment variable
# $env:TF_LOG_PATH="tf.log"

# # Set TF_PLUGIN_CACHE_DIR and TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE environment variables, if $PluginCacheDir is provided
# if (-not [string]::IsNullOrWhiteSpace($PluginCacheDir)) {
#   $env:TF_PLUGIN_CACHE_DIR = $PluginCacheDir
#   $env:TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE = $PluginCacheMayBreakDependencyLockFile
# }

# # Validate GitLab credentials
# if ([string]::IsNullOrWhiteSpace(${GitLabUser}) -or [string]::IsNullOrWhiteSpace(${GitLabToken})) {
#   Write-Output "ERROR: GitLabUser and GitLabToken environment variables must be set, please set them before running this script."
#   exit 1
# }

# # Run terraform init
# Write-Output "############################## Initializing Terraform ##############################"
# $TfStateName="github-${Scope}-${Env}"
# # TODO: to pass "GitLabProjectId" as variable
# $GitLabProjectId="65547687"

# terraform init -upgrade `
#   -backend-config="address=https://gitlab.com/api/v4/projects/${GitLabProjectId}/terraform/state/${TfStateName}" `
#   -backend-config="lock_address=https://gitlab.com/api/v4/projects/${GitLabProjectId}/terraform/state/${TfStateName}/lock" `
#   -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${GitLabProjectId}/terraform/state/${TfStateName}/lock" `
#   -backend-config="username=${GitLabUser}" `
#   -backend-config="password=${GitLabToken}" `
#   -backend-config="lock_method=POST" `
#   -backend-config="unlock_method=DELETE" `
#   -backend-config="retry_wait_min=5"

# Test-ExitCode -Message "ERROR: Terraform Initializing failed."

# # Run terraform validate
# Write-Output "############################## Validating Terraform scripts ##############################"
# terraform validate -no-color

# Test-ExitCode -Message "ERROR: Terraform Validating failed."

# switch ($Action) {
#   # Run terraform plan
#   'plan' {
#     Write-Output "############################## Planning Terraform changes ##############################"
#     # Trim and remove all whitespace from $Targets
#     $Targets = $Targets.Trim() -replace '\s+', ''
#     # Check if $Targets is empty (no targets specified)

#     if ($Targets -eq '') {
#       terraform plan -input=false -no-color -out='plan.output'
#     } else {
#       # Split multiple targets by comma and validate each
#       $targetArray = $Targets -split ','
#       $pattern = '^-target=[a-zA-Z0-9_]+\.[a-zA-Z0-9_.-]+$'
#       $validTargets = @()
#       foreach ($target in $targetArray) {
#         $target = $target.Trim()
#         if ($target -match $pattern) {
#           $validTargets += $target
#         } else {
#           Write-Output "ERROR: Invalid target format: $target"
#           Write-Output "Expected format: -target=resource_type.resource_name[..]"
#           exit 1
#         }
#       }

#       terraform plan -input=false -no-color $validTargets -out="plan.output"
#     }

#     Test-ExitCode -Message "ERROR: Terraform Planning failed."
#   }
#   # Run terraform apply
#   'apply' {
#     Write-Output "############################## Applying Terraform changes ##############################"
#     terraform apply -input=false -no-color -auto-approve 'plan.output'

#     Test-ExitCode -Message "ERROR: Terraform Applying failed."
#   }
#   'state list' {
#     Write-Output "############################## Listing Terraform State ##############################"

#     # Run terraform state list
#     terraform state list

#     Test-ExitCode -Message "ERROR: Terraform Listing failed."
#   }
#   'state move' {
#     Write-Output "############################## Moving a resource into Terraform State ##############################"
#     # Trim and remove all whitespace from $Source
#     $Source = $Source.Trim() -replace '\s+', ''
#     # Trim and remove all whitespace from $Destination
#     $Destination = $Destination.Trim() -replace '\s+', ''

#     # Run terraform move
#     # TODO: to consider to set "-dry-run"
#     terraform state mv $Source $Destination

#     Test-ExitCode -Message "ERROR: Terraform Moving failed."
#   }
#   'state remove' {
#     Write-Output "############################## Removing a resource into Terraform State ##############################"
#     # Trim and remove all whitespace from $Address
#     $Address = $Address.Trim() -replace '\s+', ''

#     # Run terraform state rm
#     # TODO: to consider to set "-dry-run"
#     # terraform state rm $Address ######################################################################################################################################################

#     Test-ExitCode -Message "ERROR: Terraform Removing failed."
#   }
#   'import' {
#     Write-Output "############################## Importing a resource into Terraform State ##############################"
#     # Trim and remove all whitespace from $Address
#     $Address = $Address.Trim() -replace '\s+', ''
#     # Trim and remove all whitespace from $Id
#     $Id = $Id.Trim() -replace '\s+', ''

#     # Run terraform import
#     # terraform import -input=false -no-color $Address $Id ######################################################################################################################################################

#     Test-ExitCode -Message "ERROR: Terraform Importing failed."
#   }
#   default {
#     Write-Output "ERROR: Invalid action specified. Valid actions are: 'plan', 'apply', 'import', 'list', 'remove', and 'move'"
#     exit 1
#   }
# }

# # Delete backend.tf and variables.tf
# Remove-Item -Path "backend.tf" -Force
# Remove-Item -Path "variables.tf" -Force

# # TODO: to investigate
# # New-Item -ItemType Directory -Path "$Path/$Env/tf_temp" -Force
# # terraform providers mirror "$Path/$Env/tf_temp"