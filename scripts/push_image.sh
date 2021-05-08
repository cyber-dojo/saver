#!/bin/bash -Ee

# - - - - - - - - - - - - - - - - - - - - - - - -
push_image()
{
  echo
  local -r image="$(image_name)"
  local -r sha="$(image_sha)"
  local -r tag=${sha:0:7}
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push ${image}:latest
  docker push ${image}:${tag}
  docker logout
}

#- - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_SAVER_IMAGE}"
}

#- - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm "$(image_name):latest" sh -c 'echo ${SHA}'
}

