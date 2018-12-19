#!/bin/bash

readonly name=saver
readonly dir=cyber-dojo
readonly uid=19663

if [[ ! -d /${dir} ]]; then
  echo "ERROR"
  echo "The ${name} service needs to volume-mount /${dir} on the host"
  echo "Please run"
  echo "  $ [sudo] mkdir /${dir}"
  echo "If you are running on Docker-Toolbox"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "(and it looks like you are)"
  fi
  echo "remember to run this on the target VM."
  echo "For example"
  echo "  \$ docker-machine ssh default 'sudo mkdir /${dir}'"
  exit 1
fi

readonly probe="for-ownership"
mkdir /${dir}/${probe} 2>/dev/null
if [ $? -ne 0 ] ; then
  echo "ERROR"
  echo "The ${name} service (uid=${uid}) needs write access to /${dir}"
  echo "Please run:"
  echo "  $ [sudo] chown ${uid} /${dir}"
  echo "If you are running on Docker-Toolbox"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "(and it looks like you are)"
  fi
  echo "remember to run this on the target VM."
  echo "For example"
  echo "  \$ docker-machine ssh default 'sudo chown ${uid} /${dir}'"
  exit 2
else
  rmdir /${dir}/${probe}
fi

# - - - - - - - - - - - - - - - - - - - - -
set -e

if [[ ! -d /${dir}/groups ]]; then
  mkdir /${dir}/groups
fi

if [[ ! -d /${dir}/katas ]]; then
  mkdir /${dir}/katas
fi

bundle exec rackup \
  --warn           \
  --host 0.0.0.0   \
  --port 4537      \
  --server thin    \
  --env production \
    config.ru
