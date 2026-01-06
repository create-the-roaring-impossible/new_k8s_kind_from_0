#!/usr/bin/env bash
set -e

# DESCRIPTION: The script is used to run Terraform commands, such as init, plan, apply, import, remove, move and list.
#              It will be used GitLab, to store the Terraform state remotely.
#
# REQUIREMENTS:
#   - The path to the Terraform scripts (TF_PATH) (mandatory)
#   - The environment to set (ENV) (mandatory)
#   - The scope to set (SCOPE) (mandatory)
#   - The action to perform (ACTION) ('plan', 'apply', 'state move', 'state list', 'state remove', 'import') (mandatory)
#   - The log level to set (LOG_LEVEL) ('INFO', 'WARN', 'ERROR', 'DEBUG', 'TRACE') (optional)
#   - The directory to use for the Terraform plugin cache (PLUGIN_CACHE_DIR) (optional)
#   - Whether the plugin cache may break the dependency lock file (PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE) ('true', 'false') (optional)
#   - The targets to use for the plan action (TARGETS) (optional)
#   - The address of the resource to import, remove or move (ADDRESS) (optional)
#   - The ID of the resource to import (ID) (optional)
#   - The source address of the resource to move (SOURCE) (optional)
#   - The destination address of the resource to move (DESTINATION) (optional)
#   - The GitLab user to use for authentication (GITLAB_USER) (mandatory)
#   - The GitLab token to use for authentication (GITLAB_TOKEN) (mandatory)
#   - The GitLab project ID to use for the Terraform state (GITLAB_PROJECT_ID) (mandatory)
#
# USAGE: bash terraform.sh -TF_PATH <path> -ENV <env> -SCOPE <scope> -ACTION <action> [-LOG_LEVEL <log_level>] [-PLUGIN_CACHE_DIR <plugin_cache_dir>] [-PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE <true|false>] [-TARGETS <targets>] [-SOURCE <source>] [-DESTINATION <destination>] [-ADDRESS <address>] [-ID <id>] -GITLAB_USER <user> -GITLAB_TOKEN <token> -GITLAB_PROJECT_ID <project_id>
#
# EXAMPLE: bash terraform.sh 'terraform/local' 'local' 'desktop-s8glse7' 'plan' 'ERROR' '-target=aws_instance.instance_name,-target=aws_s3_bucket.bucket_name' 'gitlab_user' 'gitlab_token' 'gitlab_project_id'
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
# VERSION: 1.3.1
#
# DATE: 06/01/2026

############################
########## Inputs ##########
############################

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -TF_PATH)
      TF_PATH="$2"
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
    -GITLAB_PROJECT_ID)
      GITLAB_PROJECT_ID="$2"
      shift 2
      ;;
    *)
      echo 1>&2 "ERROR: Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$TF_PATH" || -z "$ENV" || -z "$SCOPE" || -z "$ACTION" || -z "$GITLAB_USER" || -z "$GITLAB_TOKEN" || -z "$GITLAB_PROJECT_ID" ]]; then
  echo 1>&2 "ERROR: Missing required parameters"
  echo 1>&2 "Required: -TF_PATH, -ENV, -SCOPE, -ACTION, -GITLAB_USER, -GITLAB_TOKEN, -GITLAB_PROJECT_ID"
  echo 1>&2 "USAGE: bash terraform.sh -TF_PATH <path> -ENV <env> -SCOPE <scope> -ACTION <action> -GITLAB_USER <user> -GITLAB_TOKEN <token> -GITLAB_PROJECT_ID <project_id> [OPTIONS]"
  echo 1>&2 "Optional: -LOG_LEVEL <level> -PLUGIN_CACHE_DIR <dir> -PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE <true|false> -TARGETS <targets> -SOURCE <source> -DESTINATION <destination> -ADDRESS <address> -ID <id>"
  exit 1
fi

# Validate ACTION parameter
valid_actions=("plan" "apply" "state list" "state move" "state remove" "import")
if [[ ! " ${valid_actions[@]} " =~ " ${ACTION} " ]]; then
  echo 1>&2 "ERROR: Invalid 'action' specified. Valid actions are: 'plan', 'apply', 'import', 'state list', 'state remove' and 'state move'"
  exit 1
fi

# Validate LOG_LEVEL parameter
valid_log_levels=("INFO" "WARN" "ERROR" "DEBUG" "TRACE")
if [[ -n "$LOG_LEVEL" && ! " ${valid_log_levels[@]} " =~ " ${LOG_LEVEL} " ]]; then
  echo 1>&2 "ERROR: Invalid 'log_level' specified. Valid actions are: 'INFO', 'WARN', 'ERROR', 'DEBUG' and 'TRACE'"
  exit 1
fi

# Validate PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE parameter
valid_plugin_cache_may_break_dependency_lock_file=("true" "false")
if [[ -n "$PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE" && ! " ${valid_plugin_cache_may_break_dependency_lock_file[@]} " =~ " ${PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE} " ]]; then
  echo 1>&2 "ERROR: Invalid 'plugin_cache_may_break_dependency_lock_file' specified. Valid values are: 'true' and 'false'"
  exit 1
fi

###########################
######## Functions ########
###########################

function exit_code() {
  # DESCRIPTION: This function checks the last exit code and exits the script if it is not zero.
  #              It also outputs a custom error message.
  #
  # REQUIREMENTS:
  #   - The exit status to check. ($1) (Mandatory)
  #   - The error message to output if the last exit code is not zero. ($2) (Mandatory)
  #
  # USAGE: exit_code $? "<custom_error_message>"
  #
  # EXAMPLE: exit_code $? "ERROR: Terraform Listing failed."
  #          This example checks the last exit code and outputs "ERROR: Terraform Listing failed." if it is not zero.

  local exit_status="$1"
  local message="$2"

  if [[ $exit_status -ne 0 ]]; then
    echo "${message}" >&2 # to write errors to stderr, instead of stdout
    exit 1
  fi

  return 0
}

# Copy backend.tf and variables.tf, from $TF_PATH to $TF_PATH/$ENV
cp "$TF_PATH/backend.tf" "$TF_PATH/$ENV/backend.tf"
cp "$TF_PATH/variables.tf" "$TF_PATH/$ENV/variables.tf"

# Change directory to $TF_PATH/$ENV
cd "$TF_PATH/$ENV"

# Set TF_LOG environment variable, default to ERROR if LogLevel is not provided
if [[ -z "$LOG_LEVEL" ]]; then
  export TF_LOG='ERROR'
else
  export TF_LOG="$LOG_LEVEL"
fi

# Set TF_LOG_PATH environment variable
export TF_LOG_PATH="tf.log"

# Set TF_PLUGIN_CACHE_DIR and TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE environment variables, if $PLUGIN_CACHE_DIR and $TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE are provided
if [[ -n "$PLUGIN_CACHE_DIR" ]]; then
  export TF_PLUGIN_CACHE_DIR="$PLUGIN_CACHE_DIR"
  if [[ -n "$TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE" ]]; then
    export TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE="$PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE"
  fi
fi

# Validate GitLab credentials
if [[ -z "$GITLAB_USER" || -z "$GITLAB_TOKEN" || -z "$GITLAB_PROJECT_ID" ]]; then
  echo 1>&2 "ERROR: GITLAB_USER, GITLAB_TOKEN and GITLAB_PROJECT_ID environment variables must be set, please set them before running this script."
  exit 1
fi

# Run terraform init
echo "############################## Initializing Terraform ##############################"
tf_state_name="github-${SCOPE}-${ENV}"

terraform init -upgrade \
  -backend-config="address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${tf_state_name}" \
  -backend-config="lock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${tf_state_name}/lock" \
  -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${tf_state_name}/lock" \
  -backend-config="username=${GITLAB_USER}" \
  -backend-config="password=${GITLAB_TOKEN}" \
  -backend-config="lock_method=POST" \
  -backend-config="unlock_method=DELETE" \
  -backend-config="retry_wait_min=5"

exit_code $? "ERROR: Terraform Initializing failed."

# Run terraform validate
echo "############################## Validating Terraform scripts ##############################"
terraform validate -no-color

exit_code $? "ERROR: Terraform Validating failed."

case $ACTION in
  'plan')
    echo "############################## Planning Terraform changes ##############################"
    # Trim and remove all whitespace from $TARGETS
    TARGETS=$(echo "$TARGETS" | tr -d '[:space:]')

    # Check if $TARGETS is empty (no targets specified)
    if [[ -z "$TARGETS" ]]; then
      terraform plan -input=false -no-color -out='plan.output'
    else
      # Split multiple targets by comma and validate each
      IFS=',' read -ra target_array <<< "$TARGETS"
      pattern='^-target=[a-zA-Z0-9_]+\.[a-zA-Z0-9_.-]+$'
      valid_targets=()
      for target in "${target_array[@]}"; do
        target=$(echo "$target" | xargs) # Trim whitespace
        if [[ $target =~ $pattern ]]; then
          valid_targets+=("$target")
        else
          echo 1>&2 "ERROR: Invalid target format: $target"
          echo 1>&2 "Expected format: -target=resource_type.resource_name[..]"
          exit 1
        fi
      done

      terraform plan -input=false -no-color "${valid_targets[@]}" -out='plan.output'
    fi

    exit_code $? "ERROR: Terraform Planning failed."
    ;;
  'apply')
    echo "############################## Applying Terraform changes ##############################"
    terraform apply -input=false -no-color -auto-approve 'plan.output'

    exit_code $? "ERROR: Terraform Applying failed."
  ;;
  'state list')
    echo "############################## Listing Terraform State ##############################"

    terraform state list

    exit_code $? "ERROR: Terraform Listing failed."
    ;;
  'state move')
    echo "############################## Moving a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $SOURCE
    SOURCE=$(echo "$SOURCE" | tr -d '[:space:]')
    # Trim and remove all whitespace from $DESTINATION
    DESTINATION=$(echo "$DESTINATION" | tr -d '[:space:]')

    terraform state mv $SOURCE $DESTINATION # TODO: to consider to set "-dry-run"

    exit_code $? "ERROR: Terraform Moving failed."
    ;;
  'state remove')
    echo "############################## Removing a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $ADDRESS
    ADDRESS=$(echo "$ADDRESS" | tr -d '[:space:]')

    terraform state rm $ADDRESS # TODO: to consider to set "-dry-run"

    exit_code $? "ERROR: Terraform Removing failed."
    ;;
  'import')
    echo "############################## Importing a resource into Terraform State ##############################"
    # Trim and remove all whitespace from $ADDRESS
    ADDRESS=$(echo "$ADDRESS" | tr -d '[:space:]')
    # Trim and remove all whitespace from $ID
    ID=$(echo "$ID" | tr -d '[:space:]')

    terraform import -input=false -no-color $ADDRESS $ID

    exit_code $? "ERROR: Terraform Importing failed."
    ;;
  *)
    exit_code $? "ERROR: Invalid action specified. Valid actions are: 'plan', 'apply', 'state list', 'state move', 'state remove' and 'import'"
    ;;
esac

# Delete backend.tf and variables.tf
rm -rf "backend.tf"
rm -rf "variables.tf"

# TODO: to investigate
# mkdir -p "$TF_PATH/$ENV/tf_temp"
# terraform providers mirror "$TF_PATH/$ENV/tf_temp"