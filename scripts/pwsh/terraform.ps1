<#
.SYNOPSIS
  This script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.

.DESCRIPTION
  The script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.

.PARAMETER [ParameterName]
  Path: The path to the Terraform scripts. (Mandatopry)
  Env: The environment to set (e.g., local). (Mandatory)
  Scope: The scope to set (e.g., 'desktop-s8glse7'). (Mandatory)
  Action: The action to perform (e.g., plan, apply, import, remove, move, list). (Mandatory)
  LogLevel: The log level to set (INFO, WARN, ERROR, DEBUG, TRACE). (Optional)
  Targets: The targets to use for the plan action. (Optional)
  Address: The address of the resource to import, remove or move. (Optional)
  Id: The ID of the resource to import. (Optional)
  Source: The source address of the resource to move. (Optional)
  Destination: The destination address of the resource to move. (Optional)

.EXAMPLE
  .\terraform.ps1 'terraform/local' 'local' 'desktop-s8glse7' 'plan' 'ERROR' -target=<Targets> ######################################################################################################################################################
  This example runs the 'plan' action, with the specified targets.

.NOTES
  Authors: Matteo Cristiano
  Date: 26/10/2025
  Version: 1.0.0
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
  [string]$Action,
  [Parameter(Mandatory=$false)]
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
  [string]$Destination
)

# Copy variables.tf from $Path to $Path\$Env
Copy-Item -Path "$Path\variables.tf" -Destination "$Path\$Env\variables.tf"

# TEST
Get-ChildItem
Get-ChildItem -Path "$Path\$Env"

# Change directory to $Path\$Env
Set-Location -Path "$Path\$Env"

# Set TF_LOG environment variable, default to INFO if LogLevel is not provided
if ([string]::IsNullOrWhiteSpace($LogLevel)) {
  $env:TF_LOG = 'ERROR'
} else {
  $env:TF_LOG = $LogLevel
}

# Set TF_LOG_PATH environment variable
Set-Variable TF_LOG_PATH="$Path\$Env\terraform.log"

# Run terraform init, with -backend-config options
Write-Output "############################## Initializing Terraform ##############################"
# TODO: to fix "<TO_SET>" values
# terraform init -input=false -no-color -backend-config="<TO_SET>" -backend-config="key=${Scope}-${Env}.tfstate" ######################################################################################################################################################
if ($LASTEXITCODE -ne 0) {
  Write-Output "ERROR: Terraform Initializing failed."
  exit 1
}

# Run terraform validate
Write-Output "############################## Validating Terraform scripts ##############################"
# terraform validate -no-color ######################################################################################################################################################
if ($LASTEXITCODE -ne 0) {
  Write-Output "ERROR: Terraform Validating failed."
  exit 1
}

switch ($Action) {
  'plan' {
    Write-Output "############################## Planning Terraform changes ##############################"
    # Trim and remove all whitespace from $Targets
    $Targets = $Targets.Trim() -replace '\s+', ''
    # Check if $Targets is empty (no targets specified)
    if ($Targets -eq '') {
      Write-Output "Plan with NO targets"
      # terraform plan -input=false -no-color -out='plan.output' ######################################################################################################################################################
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
      # terraform plan -input=false -no-color $validTargets -out="plan.output" ######################################################################################################################################################
    }
  }
  'apply' {
    Write-Output "############################## Applying Terraform changes ##############################"
    # Run terraform apply
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

# Delete variables.tf from $Path\$Env
Remove-Item -Path "variables.tf" -Force