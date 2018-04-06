#!/usr/bin/env bash
set -e

export BUILD_TYPE="dsa-server"

# shellcheck source=../config.sh
source "$(dirname $0)/../config.sh"

for FLAVOR in ${FLAVORS[*]}
do
  docker build -f ${FLAVOR}/Dockerfile -t "iotdsa/dsa-server:${FLAVOR}" --rm=true .
done

if [[ "${@}" == *"--upload"* ]]
then
  for FLAVOR in ${FLAVORS[*]}
  do
    docker push iotdsa/dsa-server:${FLAVOR}

    if [[ ! -z ${BUILD_NUMBER} ]]
    then
      docker tag iotdsa/dsa-server:${FLAVOR} iotdsa/dsa-server:${FLAVOR}-${BUILD_NUMBER}
      docker push iotdsa/dsa-server:${FLAVOR}-${BUILD_NUMBER}
    fi
  done

  docker tag iotdsa/dsa-server:${DEFAULT_FLAVOR} iotdsa/dsa-server:latest
  docker push iotdsa/dsa-server:latest
fi
