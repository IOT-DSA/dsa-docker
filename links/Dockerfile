FROM google/dart:latest
MAINTAINER Kenneth Endfinger <k.endfinger@dglogik.com>

WORKDIR /app
VOLUME ["/data"]

COPY setup.dart run.sh util.dart /app/

# Configuration
ARG LINKS=""
ENV LINKS ${LINKS}

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes bsdtar zip unzip procps wget

RUN \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

RUN dart setup.dart

WORKDIR /data

CMD ["bash", "/app/run.sh"]
