#!/bin/bash

readonly SH_DIR="$(cd "$(dirname "${0}")" && pwd)"

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

open http://$(ip_address):4538
