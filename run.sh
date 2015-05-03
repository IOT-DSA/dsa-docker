#!/usr/bin/env bash
set -e

pushd /app/links > /dev/null

LINKS=(
  Earthquake
  Storage
  Markov
  Geofence
  YouTube
  Weather
  System
)

OUR_BROKER_URL="http://127.0.0.1:8080/conn"

if [ ! -z "${BROKER_URL}" ]
then
  OUR_BROKER_URL="${BROKER_URL}"
fi

[ ! -d /app/links/Broker ] && mkdir /app/links/Broker

pushd /app/links/Broker > /dev/null
pub global run dslink:broker &
popd > /dev/null

for LINK in "${LINKS[@]}"
do
  [ ! -d "/app/links/${LINK}" ] && mkdir "/app/links/${LINK}"
  pushd "${LINK}" > /dev/null
  export BROKER_URL="${OUR_BROKER_URL}"

  if [ -f "/app/${LINK}/tool/docker_start" ]
  then
    /app/"${LINK}"/tool/docker_start &
  elif [ -f "/app/${LINK}/bin/run.dart" ]
  then
    dart "/app/${LINK}/bin/run.dart" --broker "${BROKER_URL}" &
  elif [ -f "/app/${LINK}/index.js" ]
  then
    node "/app/${LINK}/index.js" --broker "${BROKER_URL}" &
  fi
  popd > /dev/null
done

wait
