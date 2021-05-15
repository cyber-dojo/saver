#!/bin/bash -Eeu

check_env_var()
{
  local -r name="$(server_image):$(image_tag)"
  local -r actual="$(docker run --rm ${name} sh -c 'env | grep ^SHA')"
  echo
  echo "EXPECTED: 'SHA=${COMMIT_SHA}'"
  echo "  ACTUAL: '${actual}'"
  echo
  if [ "SHA=${COMMIT_SHA}" != "${actual}" ]; then
    echo
    echo "ERROR: unexpected env-var inside image ${name}"
    echo
    exit 42
  fi
}
