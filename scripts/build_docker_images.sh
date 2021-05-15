#!/bin/bash -Eeu

build_docker_images()
{
  echo
  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=${COMMIT_SHA}
}


