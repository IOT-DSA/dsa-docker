FROM google/dart:latest
WORKDIR /app
VOLUME ["/data"]

# Configuration
ARG DIST_BUILD_ID=latest

ENV DIST_URL=https://dsa.s3.amazonaws.com/dists/dglux_server/${DIST_BUILD_ID}/dglux_server.zip

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes zip unzip procps wget

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

RUN \
  wget ${DIST_URL} -O build.zip && \
  unzip build.zip && \
  rm build.zip

EXPOSE 8080
WORKDIR /data

CMD ["/usr/bin/dart", "/app/bin/server_watcher.dart", "--log-file=logs/dglux_server.log"]
