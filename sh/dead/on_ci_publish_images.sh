#!/usr/bin/env bash
set -Eeu

pushd "${ROOT_DIR}/sh"
source "./config.sh"
popd

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_images()
{
  if ! on_ci ; then
    echo "Not on CI so not pushing images to registry"
    return
  fi

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

