#!/usr/bin/env bash
set -e

declare -A LINKS

LINKS=(
  [Earthquake]=IOT-DSA/dslink-dart-earthquake
  [Storage]=IOT-DSA/dslink-dart-storage
)

function setup_link() {
  pushd "$1" > /dev/null
  if [ -f pubspec.yaml ]
  then
    pub get
  fi

  if [ -f package.json ]
  then
    npm install
  fi

  if [ -f tool/docker_setup ]
  then
    ./tool/docker_setup
  fi
  popd > /dev/null
}

for LINK in "${!LINKS[@]}"
do
  git clone "https://github.com/${LINKS[$LINK]}.git" "${LINK}"
  setup_link "${LINK}"
done
