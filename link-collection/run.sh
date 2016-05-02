#!/usr/bin/env bash
set -e

cd /app

if [ "${UPDATE_LINKS}" == "true" ]
then
  dart setup.dart
fi

cd /data

if [ -z ${BROKER_URL} ]
then
  export BROKER_URL="http://127.0.0.1/conn"
fi

cleanup() {
  echo "Cleaning up..."
  local pids
  pids=$(jobs -pr)
  [ -n "$pids" ] && kill -KILL $pids
  exit 0
}
trap "cleanup" INT QUIT TERM EXIT

PIDS=""
SHARED_ARGS=""

function add_shared_args() {
  SHARED_ARGS="${SHARED_ARGS} ${*}"
}

add_shared_args --broker ${BROKER_URL}

if [ ! -z ${LINK_TOKEN} ]
then
  add_shared_args --token ${LINK_TOKEN}
fi

if [ ! -z ${LINK_NAME} ]
then
  add_shared_args --name ${LINK_NAME}
fi

if [ ! -z ${LINK_LOG_LEVEL} ]
then
  add_shared_args --log ${LINK_LOG_LEVEL}
fi

if [ ! -z ${LINK_ARGS} ]
then
  add_shared_args "${LINK_ARGS}"
fi

for LINK in $(cat /app/links.dat)
do
  cd /data
  if [ ! -d ${LINK} ]
  then
    mkdir ${LINK}
  fi
  cd ${LINK}
  if [ -f /app/${LINK}/bin/run.dart ]
  then
    dart /app/${LINK}/bin/run.dart ${SHARED_ARGS} &
    PIDS="${PIDS} $!"
  elif [ -x /app/${LINK}/bin/${LINK} ]
  then
    /app/${LINK}/bin/${LINK} ${SHARED_ARGS} -d /app/${LINK}/dslink.json &
    PIDS="${PIDS} $!"
  else
    echo "Failed to start ${LINK}: I don't understand how to start it."
  fi
done

waitall() { # PID...
  local errors=0
  while :; do
    for pid in "$@"; do
      shift
      if kill -0 "$pid" 2>/dev/null; then
        set -- "$@" "$pid"
      elif wait "$pid"; then
        echo "$pid exited with zero exit status."
      else
        echo "$pid exited with non-zero exit status."
        ((++errors))
      fi
    done
    (("$#" > 0)) || break
    sleep ${WAITALL_DELAY:-1}
   done
  ((errors == 0))
}

waitall ${PIDS}
