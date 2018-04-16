#!/usr/bin/env bash
set -e

cd /data
if [ ! -f /data/BUILD_NUMBER ]; then
  cp /app/BUILD_NUMBER /data/
fi
echo "${DIST_URL}" > .docker
exec /usr/bin/dart /app/bin/server_watcher.dart --log-file=logs/dglux_server.log
