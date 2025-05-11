#!/bin/bash
set -e

# DESCRIPTION: This bash script install, and start, a GitHub runner
#
# REQUIREMENTS:
# - GitHub Organization URL (GH_URL)
# - Token (TOKEN)
# - Runner Group Name (RUNNER_GRP_NAME)
# - Runner Name (RUNNER_NAME)
# - Labels List (LABELS) [optional]
#
# USAGE: bash gh-runner-start.sh $GH_URL $TOKEN $RUNNER_GRP_NAME $RUNNER_NAME [$LABELS]
#
# EXAMPLE:
# bash gh-runner-start.sh "https://github.com/create-the-roaring-impossible/new_k8s_kind_from_0" "<TOKEN>" "Docker" "DESKTOP-S8GLSE7" ["DESKTOP-S8GLSE7, docker, ubuntu-24.04"]
#
# AUTHORS: Matteo Cristiano
#
# VERSION: 1.0.0
#
# DATE: 02/02/2025

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
#     while true; do # Let's check there're no running jobs, before removing the agent
#       ./config.sh remove --unattended --auth "TOKEN" --token ${TOKEN} && break # TODO: to manage possible errors, and THEN break the loop
#       echo "There're some running jobs, retrying in 60 seconds.."
#       sleep 60
#     done
  fi
}

############################
########## Inputs ##########
############################

GH_URL=$1
if [ -z $GH_URL ]; then
  echo 1>&2 "ERROR: missing GH_URL variable"
  exit 1
fi

TOKEN=$2
if [ -z $TOKEN ]; then
  echo 1>&2 "ERROR: missing TOKEN variable"
  exit 1
fi

RUNNER_GRP_NAME=$3
if [ -z $RUNNER_GRP_NAME ]; then
  echo 1>&2 "ERROR: missing RUNNER_GRP_NAME variable"
  exit 1
fi

RUNNER_NAME=$4
if [ -z $RUNNER_NAME ]; then
  echo 1>&2 "ERROR: missing RUNNER_NAME variable"
  exit 1
fi
RUNNER_NAME=$RUNNER_NAME"_$RANDOM"
echo "Runner \"$RUNNER_NAME\" will be created"

LABELS=$5
if [ -n "$LABELS" ]; then
  # Remove spaces around commas and validate the format
  LABELS=$(echo "$LABELS" | sed 's/ *, */,/g')
  if ! [[ "$LABELS" =~ ^[a-zA-Z0-9._/-]+(,[a-zA-Z0-9._/-]+)*$ ]]; then
    echo 1>&2 "ERROR: LABELS must be a comma-separated list of alphanumeric strings, dots, underscores, dashes, or slashes, without spaces"
    exit 1
  fi
fi

#############################################
########## Create folder structure ##########
#############################################

print_header "1. Creating folder structure.."

if [ ! -d ~/gh-runners ]; then
  mkdir -p ~/gh-runners
fi
cd ~/gh-runners

if [ ! -d ~/gh-runners/$RUNNER_NAME ]; then
  mkdir -p ~/gh-runners/$RUNNER_NAME
fi
cd ~/gh-runners/$RUNNER_NAME

###################################################
########## Install GitHub Runner package ##########
###################################################

print_header "2. Determining, downloading, and extracting package to install.."

GH_RUNNER_PACKAGE=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .assets[].browser_download_url | grep "linux-x64")
if [ -z "$GH_RUNNER_PACKAGE" ]; then
  echo 1>&2 "ERROR: Could not determine GitHub Runner package to download"
  exit 1
fi

GH_RUNNER_VERSION=$(echo "$GH_RUNNER_PACKAGE" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
echo "Version $GH_RUNNER_VERSION will be installed"

curl -LsS $(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .assets[].browser_download_url | grep "linux-x64") | tar -xz
chmod +x ~/gh-runners/$RUNNER_NAME/*

###############################################
########## Configure\register runner ##########
###############################################

print_header "3. Configuring runner.."

./config.sh --unattended --name $RUNNER_NAME --url $GH_URL --token $TOKEN --runnergroup $RUNNER_GRP_NAME --replace --labels $LABELS --disableupdate

########################################################
########## Running runner ##########
########################################################

print_header "4. Running runner.."

sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status