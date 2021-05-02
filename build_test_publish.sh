#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/augmented_docker_compose.sh"
source "${SCRIPTS_DIR}/build_docker_images.sh"
source "${SCRIPTS_DIR}/check_env_var.sh"
source "${SCRIPTS_DIR}/containers_down.sh"
source "${SCRIPTS_DIR}/containers_up.sh"
source "${SCRIPTS_DIR}/on_ci_publish_tagged_images.sh"
source "${SCRIPTS_DIR}/run_tests_in_containers.sh" "$@"
source "${SCRIPTS_DIR}/tag_image.sh"
source "${SCRIPTS_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - -
build_service_images "$@"
check_env_var "$@"
tag_image "$@"
containers_up "$@"
run_tests_in_containers "$@"
containers_down
on_ci_publish_tagged_images
