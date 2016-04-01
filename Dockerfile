## Build environment for Android Open Source Project development

## from Trusted Ubuntu 14.04
FROM ubuntu:14.04
MAINTAINER Tom Hiller

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get -qq -y update && \
  apt-get install -y file dpkg-dev ccache lzop mingw32 pngcrush nano zip \
                     lib32z1-dev lib32ncurses5-dev lib32readline-gplv2-dev \
                     libbz2-1.0 libbz2-dev lib32bz2-1.0 lib32bz2-dev \
                     python2.7-minimal python-markdown libc6-dev flex tofrodos \
                     libghc-bzlib-dev libgl1-mesa-dev libncurses5-dev \
                     libreadline6-dev python-markdown schedtool curl git \
                     squashfs-tools x11proto-core-dev xsltproc liblz4-tool \
                     libxml2-utils gperf bison g++-multilib zlib1g-dev \
                     bsdmainutils openjdk-7-jdk openjdk-7-jre

## Add Repo
RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /bin/repo && \
	  chmod 755 /bin/repo

## Source config variables
RUN echo 'source /root/config/config-vars.sh' >> /etc/bash.bashrc

# Fix compile bug
# http://android-rebuilds.beuc.net/SDK_6.0.0/
RUN echo 'export USER=$(whoami)' >> /etc/bash.bashrc

## Alias build script
RUN echo 'alias build-android="/root/config/build-android.sh"' >> /etc/bash.bashrc

## Run Git config on login
RUN echo '. /root/config/git-config.sh' >> /etc/bash.bashrc

## Set ccache settings
RUN echo "export USE_CCACHE=1" >> /etc/bash.bashrc && \
    echo "export CCACHE_DIR=/srv/ccache" >> /etc/bash.bashrc && \
    CCACHE_DIR=/srv/ccache ccache -M 50G

WORKDIR /root/android
VOLUME /root/android
VOLUME /root/config
VOLUME /root/android/.repo/local_manifests
VOLUME /srv/ccache
