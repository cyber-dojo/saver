#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/augmented_docker_compose.sh"
source "${SCRIPTS_DIR}/build_docker_images.sh"
source "${SCRIPTS_DIR}/check_env_var.sh"
source "${SCRIPTS_DIR}/exit_non_zero_unless_installed.sh"
source "${SCRIPTS_DIR}/tag_image.sh"

source "${SCRIPTS_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

exit_non_zero_unless_installed docker docker-compose
build_docker_images
check_env_var
tag_image
