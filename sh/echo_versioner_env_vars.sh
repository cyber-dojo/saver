#!/usr/bin/env bash
set -Eeu

echo_versioner_env_vars()
{
  local -r sha="$(cd "$(repo_root)" && git rev-parse HEAD)"
  docker run --rm cyberdojo/versioner:latest
  echo CYBER_DOJO_SAVER_SHA="${sha}"
  echo CYBER_DOJO_SAVER_TAG="${sha:0:7}"

  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_SAVER_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/saver
}
