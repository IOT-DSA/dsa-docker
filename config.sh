#!/usr/bin/env bash

DEFAULT_FLAVOR=ubuntu
FLAVORS=()

if [[ "$(uname -m)" == "x86_64" ]]
then
  FLAVORS+=(ubuntu debian fedora)
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
echo "Links: ${DOCKER_LINKS[*]}"
echo "=========================="
