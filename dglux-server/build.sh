#!/usr/bin/env bash
set -e

export BUILD_TYPE="dglux-server"

# shellcheck source=../config.sh
source "$(dirname $0)/../config.sh"

for FLAVOR in ${FLAVORS[*]}
do
  docker build -f ${FLAVOR}/Dockerfile -t "iotdsa/dglux-server:${FLAVOR}" --rm=true .
done

if [[ "${@}" == *"--upload"* ]]
then
  for FLAVOR in ${FLAVORS[*]}
  do
    docker push iotdsa/dglux-server:${FLAVOR}

    if [[ ! -z ${BUILD_NUMBER} ]]
    then
      docker tag iotdsa/dglux-server:${FLAVOR} iotdsa/dglux-server:${FLAVOR}-${BUILD_NUMBER}
      docker push iotdsa/dglux-server:${FLAVOR}-${BUILD_NUMBER}
    fi
  done

  docker tag iotdsa/dglux-server:${DEFAULT_FLAVOR} iotdsa/dglux-server:latest
  docker push iotdsa/dglux-server:latest
fi
