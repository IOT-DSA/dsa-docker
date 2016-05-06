#!/usr/bin/env bash
set -e

export BUILD_TYPE="links"

# shellcheck source=config.sh
source "$(dirname $0)/config.sh"

cd link-collection
for LINK in ${DOCKER_LINKS[*]}
do
  for FLAVOR in ${FLAVORS[*]}
  do
    docker build -f ${FLAVOR}/Dockerfile -t "iotdsa/${LINK}:${FLAVOR}" --rm=true --build-arg LINKS="${LINK}" .
  done
done
cd ..
