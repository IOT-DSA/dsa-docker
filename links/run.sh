#!/usr/bin/env bash
set -e

cd /app
dart setup.dart
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
    dart /app/${LINK}/bin/run.dart --broker ${BROKER_URL} &
    PIDS="${PIDS} $!"
  elif [ -x /app/${LINK}/bin/${LINK} ]
  then
    /app/${LINK}/bin/${LINK} --broker ${BROKER_URL} -d /app/${LINK}/dslink.json &
    PIDS="${PIDS} $!"
  else
    echo "Failed to start ${LINK}: I don't understand how to start it."
  fi
done

cd /data

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
