#!/usr/bin/env bash
set -e

cd link-collection
docker build -t iotdsa/etsdb --rm=true --build-arg LINKS="dslink-java-etsdb" .
cd ..
