## Add Oracle Java 7 to Android Build environment

FROM android-builder-base
MAINTAINER Tom Hiller

ENV DEBIAN_FRONTEND noninteractive

## Install Oracle Java 7
RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -y && \
  apt-get install -y oracle-java7-installer	
