FROM iotdsa/base:armhf-debian
MAINTAINER Kenneth Endfinger <k.endfinger@dglogik.com>

WORKDIR /app
VOLUME ["/data"]

COPY setup.dart run.sh util.dart /app/

# Configuration
ARG LINKS
ENV LINKS ${LINKS}

RUN dart setup.dart

WORKDIR /data

CMD ["bash", "/app/run.sh"]
