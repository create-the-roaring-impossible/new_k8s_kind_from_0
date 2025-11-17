<#
.SYNOPSIS
  This script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.

.DESCRIPTION
  The script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.
  It will be used GitLab, to store the Terraform state remotely.

.PARAMETER Path
  The path to the Terraform scripts. (Mandatory)
.PARAMETER Env
  The environment to set (e.g., local). (Mandatory)
.PARAMETER Scope
  The scope to set (e.g., 'desktop-s8glse7'). (Mandatory)
.PARAMETER Action
  The action to perform (e.g., plan, apply, import, remove, move, list). (Mandatory)
.PARAMETER LogLevel
  The log level to set (INFO, WARN, ERROR, DEBUG, TRACE). (Optional)
.PARAMETER PluginCacheDir
  The directory to use for the Terraform plugin cache. (Optional)
.PARAMETER PluginCacheMayBreakDependencyLockFile
  Whether the plugin cache may break the dependency lock file. (Optional)
.PARAMETER Targets
  The targets to use for the plan action. (Optional)
.PARAMETER Address
  The address of the resource to import, remove or move. (Optional)
.PARAMETER Id
  The ID of the resource to import. (Optional)
.PARAMETER Source
  The source address of the resource to move. (Optional)
.PARAMETER Destination
  The destination address of the resource to move. (Optional)
.PARAMETER GitLabUser
  The GitLab user to use for authentication. (Mandatory)
.PARAMETER GitLabToken
  The GitLab token to use for authentication. (Mandatory)

.REQUIREMENTS
  - Terraform CLI installed
  - GitLab access token with api permissions
  - Valid GitLab project path

.USAGE
  pwsh terraform.ps1 -Path <path> -Env <env> -Scope <scope> -Action <action> [-LogLevel <level>] [-PluginCacheDir <dir>] [-PluginCacheMayBreakDependencyLockFile <true|false>] [-Targets <targets>] [-Address <address>] [-Id <id>] [-Source <source>] [-Destination <destination>] -GitLabUser <user> -GitLabToken <token>

.EXAMPLE
  pwsh terraform.ps1 -Path 'terraform/local' -Env 'local' -Scope 'desktop-s8glse7' -Action 'plan' -LogLevel 'ERROR' -Targets '-target=aws_instance.instance_name,-target=aws_s3_bucket.bucket_name' -GitLabUser 'gitlab_user' -GitLabToken 'gitlab_token'
  This example runs the 'plan' action, with the specified targets.

.AUTHORS
  Matteo Cristiano

.VERSION
  1.2.1

.DATE
  13/11/2025
#>

# Inputs
param (
  [Parameter(Mandatory=$true)]
  [string]$Path,
  [Parameter(Mandatory=$true)]
  [string]$Env,
  [Parameter(Mandatory=$true)]
  [string]$Scope,
  [Parameter(Mandatory=$true)]
  [ValidateSet('plan', 'apply', 'import', 'state remove', 'state move', 'state list')]
  [string]$Action,
  [Parameter(Mandatory=$false)]
  [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG', 'TRACE')]
  [string]$LogLevel,
  [Parameter(Mandatory=$false)]
  [string]$PluginCacheDir,
  [Parameter(Mandatory=$false)]
  [ValidateSet('true', 'false')]
  [string]$PluginCacheMayBreakDependencyLockFile,
  [Parameter(Mandatory=$false)]
  [string]$Targets,
  [Parameter(Mandatory=$false)]
  [string]$Address,
  [Parameter(Mandatory=$false)]
  [string]$Id,
  [Parameter(Mandatory=$false)]
  [string]$Source,
  [Parameter(Mandatory=$false)]
  [string]$Destination,
  [Parameter(Mandatory=$true)]
  [string]$GitLabUser,
  [Parameter(Mandatory=$true)]
  [string]$GitLabToken
)

# Copy backend.tf and variables.tf, from $Path to $Path/$Env
Copy-Item -Path "$Path/backend.tf" -Destination "$Path/$Env/backend.tf"
Copy-Item -Path "$Path/variables.tf" -Destination "$Path/$Env/variables.tf"

# Change directory to $Path/$Env
Set-Location -Path "$Path/$Env"

# Set TF_LOG environment variable, default to INFO if LogLevel is not provided
if ([string]::IsNullOrWhiteSpace($LogLevel)) {
  $env:TF_LOG = 'ERROR'
} else {
  $env:TF_LOG = $LogLevel
}

# Set TF_LOG_PATH environment variable
$env:TF_LOG_PATH="tf.log"

# Set TF_PLUGIN_CACHE_DIR and TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE environment variables, if $PluginCacheDir is provided
if (-not [string]::IsNullOrWhiteSpace($PluginCacheDir)) {
  $env:TF_PLUGIN_CACHE_DIR = $PluginCacheDir
  $env:TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE = $PluginCacheMayBreakDependencyLockFile
}

# Validate GitLab credentials
if ([string]::IsNullOrWhiteSpace(${GitLabUser}) -or [string]::IsNullOrWhiteSpace(${GitLabToken})) {
  Write-Output "ERROR: GitLabUser and GitLabToken environment variables must be set, please set them before running this script."
  exit 1
}

# Run terraform init
Write-Output "############################## Initializing Terraform ##############################"
$TfStateName="github-${Scope}-${Env}"
# TODO: to pass "GitLabProjectId" as variable
$GitLabProjectId="65547687"

terraform init -upgrade `
  -backend-config="address=https://gitlab.com/api/v4/projects/${GitLabProjectId}/terraform/state/${TfStateName}" `
  -backend-config="lock_address=https://gitlab.com/api/v4/projects/${GitLabProjectId}/terraform/state/${TfStateName}/lock" `
  -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${GitLabProjectId}/terraform/state/${TfStateName}/lock" `
  -backend-config="username=${GitLabUser}" `
  -backend-config="password=${GitLabToken}" `
  -backend-config="lock_method=POST" `
  -backend-config="unlock_method=DELETE" `
  -backend-config="retry_wait_min=5"

if ($LASTEXITCODE -ne 0) {
  Write-Output "ERROR: Terraform Initializing failed."
  exit 1
}

# Run terraform validate
Write-Output "############################## Validating Terraform scripts ##############################"
terraform validate -no-color

if ($LASTEXITCODE -ne 0) {
  Write-Output "ERROR: Terraform Validating failed."
  exit 1
}

switch ($Action) {
  # Run terraform plan
  'plan' {
    Write-Output "############################## Planning Terraform changes ##############################"
    # Trim and remove all whitespace from $Targets
    $Targets = $Targets.Trim() -replace '\s+', ''
    # Check if $Targets is empty (no targets specified)

    if ($Targets -eq '') {
      terraform plan -input=false -no-color -out='plan.output'
    } else {
      # Split multiple targets by comma and validate each
      $targetArray = $Targets -split ','
      $pattern = '^-target=[a-zA-Z0-9_]+\.[a-zA-Z0-9_.-]+$'
      $validTargets = @()
      foreach ($target in $targetArray) {
        $target = $target.Trim()
        if ($target -match $pattern) {
          $validTargets += $target
        } else {
          Write-Output "ERROR: Invalid target format: $target"
          Write-Output "Expected format: -target=resource_type.resource_name[..]"
          exit 1
        }
      }

      terraform plan -input=false -no-color $validTargets -out="plan.output"
    }

    if ($LASTEXITCODE -ne 0) {
      Write-Output "ERROR: Terraform Planning failed."
      exit 1
    }
  }
  # Run terraform apply
  'apply' {
    Write-Output "############################## Applying Terraform changes ##############################"
    terraform apply -input=false -no-color -auto-approve 'plan.output'

    if ($LASTEXITCODE -ne 0) {
      Write-Output "ERROR: Terraform Applying failed."
      exit 1
    }
  }
  'import' {
    Write-Output "############################## Importing a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $Address
    $Address = $Address.Trim() -replace '\s+', ''
    # Trim and remove all whitespace from $Id
    $Id = $Id.Trim() -replace '\s+', ''

    # Run terraform import
    # terraform import -input=false -no-color $Address $Id ######################################################################################################################################################

    if ($LASTEXITCODE -ne 0) {
      Write-Output "ERROR: Terraform Importing failed."
      exit 1
    }
  }
  'state remove' {
    Write-Output "############################## Removing a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $Address
    $Address = $Address.Trim() -replace '\s+', ''

    # Run terraform state rm
    # TODO: to consider to set "-dry-run"
    # terraform state rm $Address ######################################################################################################################################################

    if ($LASTEXITCODE -ne 0) {
      Write-Output "ERROR: Terraform Removing failed."
      exit 1
    }
  }
  'state move' {
    Write-Output "############################## Moving a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $Source
    $Source = $Source.Trim() -replace '\s+', ''
    # Trim and remove all whitespace from $Destination
    $Destination = $Destination.Trim() -replace '\s+', ''

    # Run terraform move
    # TODO: to consider to set "-dry-run"
    # terraform state mv $Source $Destination ######################################################################################################################################################

    if ($LASTEXITCODE -ne 0) {
      Write-Output "ERROR: Terraform Moving failed."
      exit 1
    }
  }
  'state list' {
    Write-Output "############################## Listing Terraform State ##############################"

    # Run terraform state list
    # terraform state list ######################################################################################################################################################

    if ($LASTEXITCODE -ne 0) {
      Write-Output "ERROR: Terraform Listing failed."
      exit 1
    }
  }
  default {
    Write-Output "ERROR: Invalid action specified. Valid actions are: 'plan', 'apply', 'import', 'list', 'remove', and 'move'"
    exit 1
  }
}

# Delete backend.tf and variables.tf
Remove-Item -Path "backend.tf" -Force
Remove-Item -Path "variables.tf" -Force

# TODO: to investigate
# New-Item -ItemType Directory -Path "$Path/$Env/tf_temp" -Force
# terraform providers mirror "$Path/$Env/tf_temp"