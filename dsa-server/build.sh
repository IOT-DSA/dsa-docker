#!/usr/bin/env bash
set -e

export BUILD_TYPE="dsa-server"

# shellcheck source=../config.sh
source "$(dirname $0)/../config.sh"

for FLAVOR in ${FLAVORS[*]}
do
  docker build --build-arg DIST_BUILD_ID=${BUILD_NUMBER} -f ${FLAVOR}/Dockerfile -t "iotdsa/dsa-server:${FLAVOR}-${BUILD_NUMBER}" --rm=true .
done

if [[ "${@}" == *"--upload"* ]]
then
  for FLAVOR in ${FLAVORS[*]}
  do
    docker push iotdsa/dsa-server:${FLAVOR}-${BUILD_NUMBER}

    if [[ "$IS_LATEST_BUILD" == "true" ]]
    then
      docker tag iotdsa/dsa-server:${FLAVOR}-${BUILD_NUMBER} iotdsa/dsa-server:${FLAVOR}-latest
      docker push iotdsa/dsa-server:${FLAVOR}-latest
    fi
  done

  if [[ "$IS_LATEST_BUILD" == "true" ]]
  then
    docker tag iotdsa/dsa-server:${DEFAULT_FLAVOR}-${BUILD_NUMBER} iotdsa/dsa-server:latest
    docker push iotdsa/dsa-server:latest
  fi
fi
