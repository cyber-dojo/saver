#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/augmented_docker_compose.sh"
source "${SCRIPTS_DIR}/build_docker_images.sh"
source "${SCRIPTS_DIR}/check_env_var.sh"
source "${SCRIPTS_DIR}/tag_image.sh"
source "${SCRIPTS_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)

build_docker_images
check_env_var
tag_image
