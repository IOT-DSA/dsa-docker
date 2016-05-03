FROM fedora:23
MAINTAINER Kenneth Endfinger <k.endfinger@dglogik.com>

ENV DART_VERSION 1.16.0
ENV JAVA_VERSION 8u92
ENV JAVA_BUILD_VERSION b14

RUN dnf -y upgrade
RUN dnf -y install wget bsdtar zip unzip python python3 python-pip python3-pip

RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm
RUN dnf -y install /tmp/jdk-8-linux-x64.rpm
RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest

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
