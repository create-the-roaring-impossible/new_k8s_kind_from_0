# DESCRIPTION: This bash script install, and start, a GitHub runner
#
# REQUIREMENTS:
# - GitHub Organization URL (GH_URL)
# - Token (TOKEN)
# - Runner Group Name (RUNNER_GRP_NAME)
# - Runner Name (RUNNER_NAME) [optional]
# - Labels List (LABELS) [optional]
#
# USAGE: bash gh-runner-start.sh $GH_URL $TOKEN $RUNNER_GRP_NAME [$RUNNER_NAME] [$LABELS]
#
# EXAMPLE: # TODO: to refactor "EXAMPLE"
# bash ado-agent-start.sh "https://dev.azure.com/fierli92/" "token" "DESKTOP-S8GLSE7 Pool" ["test-agent-name"]
#
# AUTHORS: Matteo Cristiano
#
# VERSION: 1.0.0
#
# DATE: 03/04/2025

#!/bin/bash
set -e

###############################
########## Functions ##########
###############################

print_header() {
  lightcyan="\033[1;36m"
  nocolor="\033[0m"
  echo -e "\n${lightcyan}$1${nocolor}\n"
}

cleanup() {
  trap "" EXIT
  if [ -e ./config.sh ]; then
    print_header "========== Removing agent.. =========="
    while true; do # Let's check there're no running jobs, before removing the agent
      ./config.sh remove --unattended --auth "PAT" --token ${ADO_TOKEN} && break # TODO: to manage possible errors, and THEN break the loop
      echo "There're some running jobs, retrying in 60 seconds.."
      sleep 60
    done
  fi
}

############################
########## Inputs ##########
############################

if [ -z "${ADO_URL}" ]; then
  echo 1>&2 "ERROR: missing ADO_URL variable"
  exit 1
fi

if [ -z "${ADO_TOKEN}" ]; then
  echo 1>&2 "ERROR: missing ADO_TOKEN variable"
  exit 1
fi

if [ -z "${ADO_POOL}" ]; then
  echo 1>&2 "ERROR: missing ADO_POOL variable"
  exit 1
fi

if [ -z "${ADO_AGENT_NAME}" ]; then
  ADO_AGENT_NAME="$(hostname)_${RANDOM}"
fi

########################################################
########## Install Azure DevOps Agent package ##########
########################################################

print_header "1. Determining package to install.."

AZP_AGENT_PACKAGES=$(curl -LsS -u user:${ADO_TOKEN} -H "Accept:application/json;" "${ADO_URL}/_apis/distributedtask/packages/agent?platform=${TARGETARCH}&top=1")
if [ "${AZP_AGENT_PACKAGES}" == "The resource cannot be found." ]; then
  echo 1>&2 "ERROR: could not determine package to install; check that \"${ADO_URL}\" url is valid"
  exit 1
fi
if ERROR=$(echo "${AZP_AGENT_PACKAGES}" | jq . 2>&1 >/dev/null); then
  AZP_AGENT_PACKAGE_LATEST_URL=$(echo "${AZP_AGENT_PACKAGES}" | jq -r ".value[0].downloadUrl")
else
    echo "ERROR: Invalid JSON: \"${ERROR}\""
    exit 1
fi
if [ -z "${AZP_AGENT_PACKAGE_LATEST_URL}" -o "${AZP_AGENT_PACKAGE_LATEST_URL}" == "null" ]; then
  echo 1>&2 "ERROR: could not determine package to install; check that \"${ADO_TOKEN}\" token is valid"
  exit 1
fi

echo "DONE!"

print_header "2. Downloading, and extracting, package.."

curl -LsS "${AZP_AGENT_PACKAGE_LATEST_URL}" | tar -xz & wait $! # TODO: to manage possible errors

chmod +x ./run.sh

source ./env.sh # TODO: to manage possible errors

echo "DONE!"

print_header "3. Prepare, in case of failure, to remove agent.."

trap "cleanup; exit 0" EXIT
trap "cleanup; exit 130" INT
trap "cleanup; exit 143" TERM

echo "DONE!"

print_header "4. Configuring agent.."

./config.sh --unattended --agent "${ADO_AGENT_NAME}" --url "${ADO_URL}" --auth "PAT" --token "${ADO_TOKEN}" --pool "${ADO_POOL}" --replace --acceptTeeEula & wait $!

echo "DONE!"

print_header "5. Running agent.."

# To be aware of TERM and INT signals, call "./run.sh" in background, and wait for it
# TIP: running "./run.sh" with the "--once" flag will shut down the agent, after a single pipeline is executed
./run.sh "$@" & wait $!