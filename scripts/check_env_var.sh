#!/bin/bash -Eeu

check_env_var()
{
  if [ "SHA=${COMMIT_SHA}" != "$(images_sha_env_var)" ]; then
    echo "unexpected env-var inside image ${IMAGE}:latest"
    echo "expected: 'SHA=${COMMIT_SHA}'"
    echo "  actual: '$(images_sha_env_var)'"
    exit 42
  fi
}