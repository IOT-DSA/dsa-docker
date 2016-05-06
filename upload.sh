#!/usr/bin/env bash
set -e

source config.sh

for LINK in ${DOCKER_LINKS[*]}
do
  for FLAVOR in ${FLAVORS[*]}
  do
    docker push iotdsa/${LINK}:${FLAVOR}
  done

  docker tag iotdsa/${LINK}:${DEFAULT_FLAVOR} iotdsa/${LINK}:latest
  docker push iotdsa/${LINK}:latest
done
