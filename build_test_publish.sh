#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/augmented_docker_compose.sh"
source "${SCRIPTS_DIR}/build_docker_images.sh"
source "${SCRIPTS_DIR}/containers_down.sh"
source "${SCRIPTS_DIR}/containers_up.sh"
source "${SCRIPTS_DIR}/on_ci_publish_tagged_images.sh"
source "${SCRIPTS_DIR}/run_tests_in_containers.sh" "$@"
source "${SCRIPTS_DIR}/tag_image.sh"
source "${SCRIPTS_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - -
build_service_images

if [ "SHA=${COMMIT_SHA}" != "$(images_sha_env_var)" ]; then
  echo "unexpected env-var inside image ${IMAGE}:latest"
  echo "expected: 'SHA=${COMMIT_SHA}'"
  echo "  actual: '$(images_sha_env_var)'"
  exit 42
else
  readonly TAG=${COMMIT_SHA:0:7}
  docker tag ${IMAGE}:latest ${IMAGE}:${TAG}
fi

tag_image

create_space_limited_volume

service_up saver
service_up saver_client

exit_non_zero_unless_healthy saver test-saver-server
exit_unless_clean  test-saver-server

exit_non_zero_unless_healthy saver_client test-saver-client
exit_unless_clean  test-saver-client

run_tests_in_containers
containers_down
on_ci_publish_tagged_images
