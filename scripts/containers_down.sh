#!/bin/bash -Eeu

containers_down()
{
  echo
  augmented_docker_compose \
    down \
    --remove-orphans \
    --volumes
}

