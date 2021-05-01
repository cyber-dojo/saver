#!/bin/bash -Eeu

readonly SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/scripts" && pwd )"

source "${SCRIPTS_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)
"${SCRIPTS_DIR}/build_docker_images.sh"
"${SCRIPTS_DIR}/tag_image.sh"
"${SCRIPTS_DIR}/containers_up.sh"
"${SCRIPTS_DIR}/run_tests_in_containers.sh" "$@"
"${SCRIPTS_DIR}/containers_down.sh"
"${SCRIPTS_DIR}/on_ci_publish_tagged_images.sh"
