#!/bin/bash
set -e

# Using boot2docker the VM's date-time can drift from the
# host's date-time. This affects the date displayed on eg,
# coverage stats.
#
#docker-machine ssh default "sudo date -u $(date -u +%m%d%H%M%Y)"

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
if "${SH_DIR}/run_tests_in_containers.sh" "$@"; then
  "${SH_DIR}/docker_containers_down.sh"
fi
