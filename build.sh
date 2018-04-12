#!/usr/bin/env bash
set -e

case "$1" in
"links")
  export BUILD_TYPE="links"
  ;;
"dglux-server")
  export BUILD_TYPE="dglux-server"
  export LATEST_BUILD=$(curl 'https://dsa.s3.amazonaws.com/dists/dists.json' --silent | grep "latest" | tail -1 | awk '{gsub("\"", " "); print $3}')
  ;;
"dsa-server")
  export BUILD_TYPE="dsa-server"
  export LATEST_BUILD=$(curl 'https://dsa.s3.amazonaws.com/dists/dists.json' --silent | grep "latest" | head -1 | awk '{gsub("\"", " "); print $3}')
  ;;
*)
  echo "Syntax: ./build.sh links | dglux-server | dsa-server [build number] [--upload]"
  exit
esac

if [[ ( ! -z "$2" && "$2" != "latest" )]]
then
  export BUILD_NUMBER=$2
  if [ $BUILD_NUMBER == $LATEST_BUILD ]
  then
    export IS_LATEST_BUILD=true
  else
    export IS_LATEST_BUILD=false
  fi
else
  export BUILD_NUMBER="latest"
  export IS_LATEST_BUILD=true
fi

# shellcheck source=config.sh
source "$(dirname $0)/config.sh"

if [[ "$BUILD_TYPE" == "links" ]]; then
  cd link-collection
  for LINK in ${DOCKER_LINKS[*]}
  do
    for FLAVOR in ${FLAVORS[*]}
    do
      docker build -f ${FLAVOR}/Dockerfile -t "iotdsa/${LINK}:${FLAVOR}" --rm=true --build-arg LINKS="${LINK}" .
    done
  done
  cd ..
elif [[ "$BUILD_TYPE" == "dglux-server" ]]; then
  cd dglux-server
  ./build.sh "${@}"
  cd ..
elif [[ "$BUILD_TYPE" == "dsa-server" ]]; then
  cd dsa-server
  ./build.sh "${@}"
  cd ..
fi
