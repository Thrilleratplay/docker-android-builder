#!/bin/bash
MY_DIR=$(dirname $0)
source ${MY_DIR}/config/config-vars.sh

BUILD_NAME_LC=$(echo $BUILD_NAME | tr '[A-Z]' '[a-z]')

# Host Shared Directories
HOST_SOURCE=$(pwd)/$BUILD_NAME
HOST_CCACHE=$(pwd)/$BUILD_NAME"_ccache"
HOST_CONFIG=$(pwd)/config
HOST_LOCAL_MANIFESTS=$(pwd)/$BUILD_NAME"_local_manifests"

DOCKER_SOURCE="/root/android"
DOCKER_CCACHE="/srv/ccache"
DOCKER_CONFIG="/root/config"
DOCKER_LOCAL_MANIFESTS="/root/android/.repo/local_manifests"

CONTAINER_NAME=$BUILD_NAME_LC"_"$BRANCH
IMAGE_NAME="android-builder"

# Create shared folders then have git and docker ignore them
mkdir -p $HOST_SOURCE
mkdir -p $HOST_CCACHE
grep -q "/$BUILD_NAME" .gitignore || echo "/$BUILD_NAME" >> .gitignore
grep -q "/"$BUILD_NAME"_ccache" .gitignore || echo "/"$BUILD_NAME"_ccache" >> .gitignore
grep -q "/"$BUILD_NAME"_local_manifests" .gitignore || echo "/"$BUILD_NAME"_local_manifests" >> .gitignore
grep -q "$BUILD_NAME" .dockerignore  || echo "$BUILD_NAME" >> .dockerignore
grep -q $BUILD_NAME"_ccache" .dockerignore || echo $BUILD_NAME"_ccache" >> .dockerignore
grep -q $BUILD_NAME"_local_manifests" .dockerignore || echo $BUILD_NAME"_local_manifests" >> .dockerignore

# Check if local_manifests exists
if [ ! -d $HOST_LOCAL_MANIFESTS ]; then
  mkdir $HOST_LOCAL_MANIFESTS;
fi

# Build image if needed
IMAGE_EXISTS=$(docker images -q $IMAGE_NAME)
if [ $? -ne 0 ]; then
	echo "docker command not found"
	exit $?
elif [[ -z $IMAGE_EXISTS ]]; then
	echo "Building Docker image $IMAGE_NAME..."
	docker build --no-cache --rm -t "$IMAGE_NAME" .
fi

# With the given name $CONTAINER_NAME, reconnect to running container, start
# an existing/stopped container or run a new one if one does not exist.
IS_RUNNING=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)
if [[ $IS_RUNNING == "true" ]]; then
	docker attach $CONTAINER_NAME
elif [[ $IS_RUNNING == "false" ]]; then
	docker start -i $CONTAINER_NAME
else
	docker run --privileged \
		   -v ${HOST_SOURCE}:${DOCKER_SOURCE} \
		   -v ${HOST_CCACHE}:${DOCKER_CCACHE} \
		   -v ${HOST_CONFIG}:${DOCKER_CONFIG} \
		   -v ${HOST_LOCAL_MANIFESTS}:${DOCKER_LOCAL_MANIFESTS} \
		   -v /dev/bus/usb:/dev/bus/usb \
		   -i -t --name $CONTAINER_NAME $IMAGE_NAME \
			   bash
fi

exit $?
