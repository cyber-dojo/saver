#!/bin/bash -Eeu

readonly IMAGE=cyberdojo/saver
export COMMIT_SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

build_docker_images()
{
  echo
  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=${COMMIT_SHA}
}

images_sha_env_var()
{
  docker run --rm ${IMAGE}:latest sh -c 'env | grep ^SHA'
}

