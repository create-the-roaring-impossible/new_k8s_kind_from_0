# DESCRIPTION: This script delete locally "latest", and "${tag}", tags of an image.
#              It requires to install Docker on the machine where it is executed.
#
# REQUIREMENTS:
#   - Docker Image (IMAGE)
#   - Tag (TAG)
#
# USAGE: bash docker_clean.sh $IMAGE $TAG
#
# EXAMPLE: bash docker_clean.sh ASDASDASD 1.0.0
#
# NOTES: Ensure you have the necessary permissions to execute this script.
#        Make sure all required dependencies are installed.
#
# AUTHORS: Matteo Cristiano <slb6113@gmail.com>
#
# VERSION: 1.0.0
#
# DATE: 23/08/2025

############################
########## Inputs ##########
############################

IMAGE=$1
if [ -z $IMAGE ]; then
  echo 1>&2 "ERROR: missing IMAGE variable"
  exit 1
fi

TAG=$2
if [ -z $TAG ]; then
  echo 1>&2 "ERROR: missing TAG variable"
  exit 1
fi

# Delete "${TAG}" tag of "${IMAGE}" image, if exists
if docker image inspect ${IMAGE}:${TAG} > /dev/null 2>&1; then
  docker rmi ${IMAGE}:${TAG}
fi

# Delete "latest" tag of "${IMAGE}" image, if exists
if docker image inspect ${IMAGE}:latest > /dev/null 2>&1; then
  docker rmi ${IMAGE}:latest
fi

# Check images
docker image ls