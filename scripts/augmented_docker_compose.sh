#!/bin/bash -Eeu

# cyberdojo/service-yaml image lives at
# https://github.com/cyber-dojo-tools/service-yaml

# - - - - - - - - - - - - - - - - - - - - - -
augmented_docker_compose()
{
  local -r image=cyberdojo/service-yaml
  cd "${ROOT_DIR}" && cat "./docker-compose.yml" \
    | docker run \
        --rm \
        --interactive \
        ${image} \
           custom-start-points `# for testing` \
    | tee /tmp/augmented-docker-compose.saver.peek.yml \
    | docker-compose \
      --file -       \
      "$@"
}
