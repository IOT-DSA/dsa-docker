#!/usr/bin/env bash
set -e

cd /data
echo "${DIST_URL}" > .docker
exec /usr/bin/dart /app/bin/server_watcher.dart --log-file=logs/dglux_server.log
