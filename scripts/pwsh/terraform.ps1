<#
.SYNOPSIS
  This script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.

.DESCRIPTION
  The script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.
  It will be used GitLab, to store the Terraform state remotely.

.PARAMETER Path
  Path: The path to the Terraform scripts. (Mandatory)
.PARAMETER Env
  Env: The environment to set (e.g., local). (Mandatory)
.PARAMETER Scope
  Scope: The scope to set (e.g., 'desktop-s8glse7'). (Mandatory)
.PARAMETER Action
  Action: The action to perform (e.g., plan, apply, import, remove, move, list). (Mandatory)
.PARAMETER LogLevel
  LogLevel: The log level to set (INFO, WARN, ERROR, DEBUG, TRACE). (Optional)
.PARAMETER Targets
  Targets: The targets to use for the plan action. (Optional)
.PARAMETER Address
  Address: The address of the resource to import, remove or move. (Optional)
.PARAMETER Id
  Id: The ID of the resource to import. (Optional)
.PARAMETER Source
  Source: The source address of the resource to move. (Optional)
.PARAMETER Destination
  Destination: The destination address of the resource to move. (Optional)
.PARAMETER GitLabUser
  GitLabUser: The GitLab user to use for authentication. (Mandatory)
.PARAMETER GitLabToken
  GitLabToken: The GitLab token to use for authentication. (Mandatory)

.REQUIREMENTS
  - Terraform CLI installed
  - GitLab access token with api permissions
  - Valid GitLab project path

.USAGE
  pwsh terraform.ps1 -Path <path> -Env <env> -Scope <scope> -Action <action> [-LogLevel <level>] [-Targets <targets>] [-Address <address>] [-Id <id>] [-Source <source>] [-Destination <destination>] -GitLabUser <user> -GitLabToken <token>

.EXAMPLE
  pwsh terraform.ps1 -Path 'terraform/local' -Env 'local' -Scope 'desktop-s8glse7' -Action 'plan' -LogLevel 'ERROR' -Targets '-target=aws_instance.instance_name,-target=aws_s3_bucket.bucket_name' -GitLabUser 'gitlab_user' -GitLabToken 'gitlab_token'
  This example runs the 'plan' action, with the specified targets.

.AUTHORS
  Matteo Cristiano

.VERSION
  1.1.0

.DATE
  27/10/2025
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
  # [ValidateSet('plan', 'apply', 'import', 'state remove', 'state move', 'state list')]
  [string]$Action,
  [Parameter(Mandatory=$false)]
  # [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG', 'TRACE')]
  [string]$LogLevel,
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

# # Set TF_LOG_PATH environment variable
# $env:TF_LOG_PATH="$Path/$Env/terraform.log"

# Validate GitLab credentials
if ([string]::IsNullOrWhiteSpace(${GitLabUser}) -or [string]::IsNullOrWhiteSpace(${GitLabToken})) {
  Write-Output "ERROR: GitLabUser and GitLabToken environment variables must be set, please set them before running this script."
  exit 1
}

# Run terraform init
Write-Output "############################## Initializing Terraform ##############################"
$TF_STATE_NAME="${Scope}-${Env}"
$gitlabProject = "create-the-roaring-impossible%2Fnew_k8s_kind_from_0"

terraform init `
  -backend-config="address=https://gitlab.com/api/v4/projects/${gitlabProject}/terraform/state/${TF_STATE_NAME}" `
  -backend-config="lock_address=https://gitlab.com/api/v4/projects/${gitlabProject}/terraform/state/${TF_STATE_NAME}/lock" `
  -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${gitlabProject}/terraform/state/${TF_STATE_NAME}/lock" `
  -backend-config="username=${GitLabUser}" `
  -backend-config="password=${GitLabToken}" `
  -backend-config="lock_method=POST" `
  -backend-config="unlock_method=DELETE" `
  -backend-config="retry_wait_min=5"
  # -backend-config="address=https://gitlab.com/api/v4/projects/65547687/terraform/state/${TF_STATE_NAME}" `
  # -backend-config="lock_address=https://gitlab.com/api/v4/projects/65547687/terraform/state/${TF_STATE_NAME}/lock" `
  # -backend-config="unlock_address=https://gitlab.com/api/v4/projects/65547687/terraform/state/${TF_STATE_NAME}/lock" `

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
      Write-Output "Plan with NO targets"
      terraform plan -input=false -no-color -out='plan.output'
      Write-Output "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
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
      Write-Output "Plan with targets: $($validTargets -join ' ')"
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
    # terraform apply -input=false -no-color -auto-approve 'plan.output' ######################################################################################################################################################
  }
  'import' {
    Write-Output "############################## Importing a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $Address
    $Address = $Address.Trim() -replace '\s+', ''
    # Trim and remove all whitespace from $Id
    $Id = $Id.Trim() -replace '\s+', ''
    # Run terraform import
    # terraform import -input=false -no-color $Address $Id ######################################################################################################################################################
  }
  'state remove' {
    Write-Output "############################## Removing a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $Address
    $Address = $Address.Trim() -replace '\s+', ''
    # Run terraform state rm
    # TODO: to consider to set "-dry-run"
    # terraform state rm $Address ######################################################################################################################################################
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
  }
  'state list' {
    Write-Output "############################## Listing Terraform State ##############################"
    # Run terraform state list
    # terraform state list ######################################################################################################################################################
  }
  default {
    Write-Output "ERROR: Invalid action specified. Valid actions are: 'plan', 'apply', 'import', 'list', 'remove', and 'move'"
    exit 1
  }
}

# Delete backend.tf and variables.tf
Remove-Item -Path "backend.tf" -Force
Remove-Item -Path "variables.tf" -Force

# Write-Output "######################################################################################################################################################"
# Get-Content $env:TF_LOG_PATH
# Write-Output "######################################################################################################################################################"
# Get-Content plan.output
# Write-Output "######################################################################################################################################################"