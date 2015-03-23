#!/bin/bash
MY_DIR=$(dirname $0)
source ${MY_DIR}/config/android-build-vars.sh

BUILD_NAME_LC=$(echo $BUILD_NAME | tr '[A-Z]' '[a-z]')

# Host Shared Directories
HOST_SOURCE=$(pwd)/$BUILD_NAME
HOST_CCACHE=$(pwd)/$BUILD_NAME"_ccache"
HOST_CONFIG=$(pwd)/config

DOCKER_SOURCE="/root/android"
DOCKER_CCACHE="/srv/ccache"
DOCKER_CONFIG="/root/config"

CONTAINER_NAME=$BUILD_NAME_LC"_"$BRANCH

if [[ $USE_ORACLE_JAVA == "true" ]]; then
	IMAGE_NAME="android-builder-oracle"
else 
	IMAGE_NAME="android-builder-openjdk"
fi

# Create shared folders then have git and docker ignore them
mkdir -p $HOST_SOURCE
mkdir -p $HOST_CCACHE
grep -q "/$BUILD_NAME" .gitignore || echo "/$BUILD_NAME" >> .gitignore 
grep -q "/"$BUILD_NAME"_ccache" .gitignore || echo "/"$BUILD_NAME"_ccache" >> .gitignore
grep -q "$BUILD_NAME" .dockerignore  || echo "$BUILD_NAME" >> .dockerignore 
grep -q $BUILD_NAME"_ccache" .dockerignore || echo $BUILD_NAME"_ccache" >> .dockerignore 
if [ "$MY_DIR" != "$(pwd)" ]; then
        cp -r "${MY_DIR}/config" .
fi

# This is left here commented out, use it in case you have selinux
# and your docker doesn't yet understand the :Z values for volumes
# that are used at docker run command at the bottom.
#if [ "$(getenforce)" == "Enforcing" ]; then
#        echo "We need sudo for selinux changes, possibly asking password next."
#        sudo chcon -R -t svirt_sandbox_file_t config "${BUILD_NAME}_ccache" "$BUILD_NAME"
#fi

# Build image if needed
IMAGE_EXISTS=$(docker images -q $IMAGE_NAME)
if [ $? -ne 0 ]; then
	echo "docker command not found"
	exit $?
elif [[ -z $IMAGE_EXISTS ]]; then
	echo "Building Docker image $IMAGE_NAME..."
	docker build --no-cache --rm -t android-builder-base ${MY_DIR}/dockerfiles/android-builder-base && \
	  docker build --no-cache --rm -t "$IMAGE_NAME" ${MY_DIR}/dockerfiles/$IMAGE_NAME && \
	  docker rmi android-builder-base 
fi

# With the given name $CONTAINER_NAME, reconnect to running container, start
# an existing/stopped container or run a new one if one does not exist.
IS_RUNNING=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)
if [[ $IS_RUNNING == "true" ]]; then
	docker attach $CONTAINER_NAME
elif [[ $IS_RUNNING == "false" ]]; then
	docker start -i $CONTAINER_NAME
else
	docker run -v ${HOST_SOURCE}:${DOCKER_SOURCE}:Z \
			   -v ${HOST_CCACHE}:${DOCKER_CCACHE}:Z \
			   -v ${HOST_CONFIG}:${DOCKER_CONFIG}:Z \
			   -i -t --name $CONTAINER_NAME $IMAGE_NAME \
			   bash -c "byobu"
fi

exit $?
