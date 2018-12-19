#!/bin/bash

if [[ ! -d /cyber-dojo ]]; then
  echo 'ERROR'
  echo 'The saver service needs to volume-mount /cyber-dojo on the host'
  echo 'Please run'
  echo '  $ [sudo] mkdir /cyber-dojo'
  echo 'If you are running on Docker-Toolbox'
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
  echo "(and it looks like you are)"
  fi
  echo 'remember to run this on the target VM.'
  echo 'For example'
  echo "  \$ docker-machine ssh default 'sudo mkdir /cyber-dojo'"
  exit 1
fi

readonly probe="for-ownership"
mkdir /cyber-dojo/${probe} 2>/dev/null
if [ $? -ne 0 ] ; then
  echo 'ERROR'
  echo 'The saver service (uid=19663) needs write access to /cyber-dojo'
  echo 'Please run:'
  echo '  $ [sudo] chown 19663 /cyber-dojo'
  echo 'If you are running on Docker-Toolbox'
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
  echo "(and it looks like you are)"
  fi
  echo 'remember to run this on the target VM.'
  echo 'For example'
  echo "  \$ docker-machine ssh default 'sudo chown 19663 /cyber-dojo'"
  exit 2
else
  rmdir /cyber-dojo/${probe}
fi

# - - - - - - - - - - - - - - - - - - - - -
set -e

if [[ ! -d /cyber-dojo/groups ]]; then
  mkdir /cyber-dojo/groups
fi

if [[ ! -d /cyber-dojo/katas ]]; then
  mkdir /cyber-dojo/katas
fi

# - - - - - - - - - - - - - - - - - - - - -

bundle exec rackup \
  --warn \
  --host 0.0.0.0 \
  --port 4537 \
  --server thin \
  --env production \
    config.ru
