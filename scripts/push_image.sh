#!/bin/bash -Ee

# - - - - - - - - - - - - - - - - - - - - - - - -
push_image()
{
  echo
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push $(server_image):$(image_tag)
  docker tag  $(server_image):latest $(server_image):$(image_tag)
  docker push $(server_image):latest
  docker logout
}

