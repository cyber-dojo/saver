#!/bin/bash -Eeu

images_build()
{
  echo
  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=${COMMIT_SHA}
}
