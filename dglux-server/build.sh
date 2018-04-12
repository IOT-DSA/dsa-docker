#!/usr/bin/env bash
set -e

export BUILD_TYPE="dglux-server"

# shellcheck source=../config.sh
source "$(dirname $0)/../config.sh"

for FLAVOR in ${FLAVORS[*]}
do
  docker build --build-arg DIST_BUILD_ID=${BUILD_NUMBER} -f ${FLAVOR}/Dockerfile -t "iotdsa/dglux-server:${FLAVOR}-${BUILD_NUMBER}" --rm=true .
done

if [[ "${@}" == *"--upload"* ]]
then
  for FLAVOR in ${FLAVORS[*]}
  do
    docker push iotdsa/dglux-server:${FLAVOR}-${BUILD_NUMBER}

    if [[ "$IS_LATEST_BUILD" == "true" ]]
    then
      docker tag iotdsa/dglux-server:${FLAVOR}-${BUILD_NUMBER} iotdsa/dglux-server:${FLAVOR}-latest
      docker push iotdsa/dglux-server:${FLAVOR}-latest
    fi
  done

  if [[ "$IS_LATEST_BUILD" == "true" ]]
  then
    docker tag iotdsa/dglux-server:${DEFAULT_FLAVOR}-${BUILD_NUMBER} iotdsa/dglux-server:latest
    docker push iotdsa/dglux-server:latest
  fi
fi
