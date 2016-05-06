#!/usr/bin/env bash

DEFAULT_FLAVOR=ubuntu
FLAVORS=()

if [[ "$(uname -m)" == "x86_64" ]]
then
  FLAVORS+=(ubuntu debian)
elif [[ "$(uname -m)" == "arm"* ]]
then
  FLAVORS+=(armhf armhf-debian)
fi

DOCKER_LINKS=(
  dslink-java-etsdb
  dslink-java-mqtt
  dslink-dart-schedule
  dslink-dart-dql
  dslink-dart-weather
  dslink-dart-system
)

echo "== Docker Configuration =="
echo "Default Flavor: ${DEFAULT_FLAVOR}"
echo "Flavors: ${FLAVORS[*]}"

if [[ -z "${BUILD_TYPE}" ]] || [[ "${BUILD_TYPE}" == "links" ]]
then
  echo "Links: ${DOCKER_LINKS[*]}"
fi
echo "=========================="
