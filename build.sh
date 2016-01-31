#!/usr/bin/env bash
set -e

source config.sh

cd link-collection
for LINK in ${DOCKER_LINKS}
do
  docker build -t iotdsa/${LINK} --rm=true --build-arg LINKS="${LINK}" .
done
cd ..
