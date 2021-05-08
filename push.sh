#!/bin/bash -Ee

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/push_image.sh"
source "${SCRIPTS_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)

push_image
