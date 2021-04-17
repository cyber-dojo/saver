#!/bin/bash

readonly service_name=saver
readonly dir=cyber-dojo
readonly uid=19663
readonly username=saver
readonly gid=65533
readonly group=nogroup
readonly vm_target=${DOCKER_MACHINE_NAME:-default}

if [ ! -d /${dir} ]; then
  cmd="mkdir /${dir}"
  echo "ERROR"
  echo "The ${service_name} service needs to volume-mount /${dir}"
  echo "Please run:"
  echo "  \$ [sudo] ${cmd}"
  echo "If you are running on Docker-Toolbox remember"
  echo "to run this on the target VM. For example:"
  echo "  \$ docker-machine ssh ${vm_target} sudo ${cmd}"
  exit 1
fi

readonly probe="for-ownership"
mkdir /${dir}/${probe} 2>/dev/null
if [ $? -ne 0 ] ; then
  cmd="chown ${uid}:${gid} /${dir}"
  echo "ERROR"
  echo "The ${service_name} service needs write access to /${dir}"
  echo "username=${username} (uid=${uid})"
  echo "group=${group} (gid=${gid})"
  echo "Please run:"
  echo "  $ [sudo] ${cmd}"
  echo "If you are running on Docker-Toolbox remember"
  echo "to run this on the target VM. For example:"
  echo "  \$ docker-machine ssh ${vm_target} sudo ${cmd}"
  exit 2
else
  rmdir /${dir}/${probe}
fi

# - - - - - - - - - - - - - - - - - - - - -
set -e

if [ ! -d /${dir}/groups ]; then
  mkdir /${dir}/groups
fi

if [ ! -d /${dir}/katas ]; then
  mkdir /${dir}/katas
fi

export RUBYOPT='-W2'

rackup             \
  --warn           \
  --host 0.0.0.0   \
  --port 4537      \
  --server thin    \
  --env production \
    /app/config/config.ru
