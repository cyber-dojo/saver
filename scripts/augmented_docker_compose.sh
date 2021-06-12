#!/bin/bash -Eeu

augmented_docker_compose()
{
  # The --project-name option is important in CI pipeline
  # runs which have their own root directory name.	
  docker-compose \
    --project-name saver \
    --file "${ROOT_DIR}/docker-compose.yml" \
  	"$@"	
}