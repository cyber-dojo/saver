#!/usr/bin/env bash
set -Eeu

#echo_versioner_env_vars()
#{
#  local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
#  docker run --rm cyberdojo/versioner:latest
#
#  echo COMMIT_TAG="${sha:0:7}"
#
#  echo CYBER_DOJO_SAVER_SHA="${sha}"
#  echo CYBER_DOJO_SAVER_TAG="${sha:0:7}"
#
#  echo CYBER_DOJO_SAVER_SERVER_USER=saver
#  echo CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME=test_saver_server
#
#  echo CYBER_DOJO_SAVER_CLIENT_USER=nobody
#  echo CYBER_DOJO_SAVER_CLIENT_CONTAINER_NAME=test_saver_client
#
#  local -r AWS_ACCOUNT_ID=244531986313
#  local -r AWS_REGION=eu-central-1
#  echo CYBER_DOJO_SAVER_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/saver
#}
