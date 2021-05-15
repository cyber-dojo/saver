#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
push_image()
{
  local -r tag="${1:-}"
  echo
  # DOCKER_USER, DOCKER_PASS are in the ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  if [ "${tag}" == '' ]; then
    docker push $(server_image):$(image_tag)
  fi
  if [ "${tag}" == latest ]; then
    docker tag  $(server_image):$(image_tag) $(server_image):latest
    docker push $(server_image):latest
  fi
  docker logout
}

