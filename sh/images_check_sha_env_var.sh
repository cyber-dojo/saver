#!/usr/bin/env bash
set -Eeu

# See comment in tag_images_to_latest.sh

images_check_sha_env_var()
{
  check_sha_env_var server "$(server_image)"
  check_sha_env_var client "$(client_image)"
}

check_sha_env_var()
{
  local -r type="${1}"
  local -r image_name="${2}:$(image_tag)"
  local -r expected="SHA=${COMMIT_SHA}"
  local -r actual="$(docker run --rm ${image_name} sh -c 'env | grep ^SHA')"
  echo
  echo "${type}"
  echo "EXPECTED: '${expected}'"
  echo "  ACTUAL: '${actual}'"
  echo
  if [ "${expected}" != "${actual}" ]; then
    echo
    echo "ERROR: unexpected env-var inside image ${image_name}"
    echo
    exit 42
  fi
}
