FROM armbuild/debian:jessie
MAINTAINER Kenneth Endfinger <k.endfinger@dglogik.com>

# Use Dart Version 1.16.0
ENV DART_VERSION 1.16.0

# Install base software
RUN apt-get update && \
  apt-get install -y --force-yes zip unzip bsdtar openssl procps wget python2.7 software-properties-common python-software-properties && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer && \
  apt-get clean && rm -rf /tmp/* /var/tmp/*
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Dart
RUN \
  cd /opt && \
  wget https://commondatastorage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-arm-release.zip -O dart-sdk.zip && \
  unzip dart-sdk.zip && \
  ln -s /opt/dart-sdk/bin/dart /usr/bin/dart && \
  ln -s /opt/dart-sdk/bin/pub /usr/bin/pub && \
  ln -s /opt/dart-sdk/bin/dartanalyzer /usr/bin/dartanalyzer && \
  ln -s /opt/dart-sdk/bin/dart2js /usr/bin/dart2js && \
  ln -s /opt/dart-sdk/bin/dartdoc /usr/bin/dartdoc && \
  rm dart-sdk.zip

ENV DART_SDK /usr/lib/dart
ENV PATH ${DART_SDK}/bin:${PATH}
