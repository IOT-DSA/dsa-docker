#!/usr/bin/env bash
set -e

for name in $(grep -l "FROM " -r . | grep "Dockerfile" | xargs dirname | sed 's/\.\///')
do
  tag="${name}"

  if [[ "${name}" == "arm"* ]] && [[ "$(uname -m)" != "arm"* ]]
  then
    continue
  fi

  if [[ "${name}" != "arm"* ]] && [[ "$(uname -m)" == "arm"* ]]
  then
    continue
  fi

  cd "${name}"

  if [[ "${name}" == "ubuntu" ]]
  then
    tag=latest
  fi

  run_build=true
  if [[ "${@}" == *"--no-build"* ]]
  then
    run_build=false
  fi

  if [[ "${@}" == *"--build-${name}"* ]]
  then
    run_build=true
  fi

  if [[ "${run_build}" == "true" ]]
  then
    echo "==== Build base image for ${name} ===="
    docker build -t "iotdsa/base:${name}" .
  fi

  if [[ "${@}" == *"--push"* ]]
  then
    docker push "iotdsa/base:${name}"
  fi

  if [[ "${name}" != "${tag}" ]]
  then
    docker tag "iotdsa/base:${name}" "iotdsa/base:${tag}"
    if [[ "${@}" == *"--push"* ]]
    then
      docker push "iotdsa/base:${tag}"
    fi
  fi
  cd ..
done
