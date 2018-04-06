FROM ubuntu:16.04
MAINTAINER Kenneth Endfinger <k.endfinger@dglogik.com>

# Use Dart Version 1.17.1
ENV DART_VERSION 1.17.1

# Install base software
RUN apt-get update && \
  apt-get install -y --force-yes zip unzip bsdtar openssl procps wget python2.7 software-properties-common python-software-properties && \
  apt-get clean && rm -rf /tmp/* /var/tmp/*

# Install Java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/cache/oracle-jdk8-installer && \
  apt-get clean && rm -rf /tmp/* /var/tmp/*
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Dart
RUN \
  apt-get -q update && apt-get install --no-install-recommends -y -q curl git ca-certificates apt-transport-https && \
  curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
  curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list && \
  apt-get update && \
  apt-get install dart=${DART_VERSION}-1 && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DART_SDK /usr/lib/dart
ENV PATH ${DART_SDK}/bin:${PATH}
