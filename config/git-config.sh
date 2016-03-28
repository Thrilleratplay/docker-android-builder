#!/bin/bash

GLOBAL_GIT_USERNAME=$(git config --global --get user.name)

if [ -z $GLOBAL_GIT_USERNAME ]; then
  git config --global user.email $GIT_EMAIL
  git config --global user.name $GIT_USERNAME
  git config --global color.ui auto
fi
