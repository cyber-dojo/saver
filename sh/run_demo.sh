#!/bin/bash

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"

echo 'port=4538'
