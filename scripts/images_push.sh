#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/config.sh"

source "${SCRIPTS_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - - -
images_push()
{
  local -r tag="${1:-}"
  echo
  # DOCKER_USER, DOCKER_PASS are in the ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  if [ "${tag}" == '' ]; then
    docker push $(server_image):$(image_tag)
  fi
  if [ "${tag}" == latest ]; then
    docker pull $(server_image):$(image_tag)
    docker tag  $(server_image):$(image_tag) $(server_image):latest
    docker push $(server_image):latest
  fi
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
images_push "${1:-}"
