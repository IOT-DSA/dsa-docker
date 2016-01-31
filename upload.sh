#!/usr/bin/env bash
set -e

source config.sh

for LINK in ${DOCKER_LINKS[*]}
do
  docker push iotdsa/${LINK}:latest
done
