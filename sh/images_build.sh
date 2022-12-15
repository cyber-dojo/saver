#!/usr/bin/env bash
set -Eeu

images_build()
{
  echo
  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=${COMMIT_SHA}
}
