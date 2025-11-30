#!/bin/bash
readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly service_name=saver
readonly dir=cyber-dojo
readonly uid=19663
readonly username=saver
readonly gid=65533
readonly group=nogroup

if [ ! -d /${dir} ]; then
  cmd="mkdir /${dir}"
  echo "ERROR"
  echo "The ${service_name} service needs to volume-mount /${dir}"
  echo "Please run:"
  echo "  \$ [sudo] ${cmd}"
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

readonly PORT="${CYBER_DOJO_SAVER_PORT}"

puma \
  --port=${PORT} \
  --config=${MY_DIR}/puma.rb

