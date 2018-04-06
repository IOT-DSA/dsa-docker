FROM iotdsa/base:armhf

RUN mkdir /data
WORKDIR /app
VOLUME ["/data"]

# Configuration
ARG DIST_BUILD_ID=latest
ARG DIST_URL=https://dsa.s3.amazonaws.com/dists/dsa_server/${DIST_BUILD_ID}/dsa_server.zip
ENV DIST_URL ${DIST_URL}

COPY run.sh /app/

RUN \
  wget ${DIST_URL} -O build.zip && \
  unzip build.zip && \
  rm build.zip

EXPOSE 80 443
WORKDIR /data

CMD ["/app/run.sh"]
