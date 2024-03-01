#!/usr/bin/env bash
set -Eeu

images_build()
{
  echo
  docker compose \
    build \
    --build-arg COMMIT_SHA=${COMMIT_SHA}
}
