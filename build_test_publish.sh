#!/bin/bash -Eeu

readonly SH_DIR="$( cd "$( dirname "${0}" )/sh" && pwd )"

source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/tag_image.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/run_tests_in_containers.sh" "$@"
"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/on_ci_publish_tagged_images.sh"
#${SH_DIR}/trigger_dependent_images.sh
