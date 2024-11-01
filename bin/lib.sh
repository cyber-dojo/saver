#!/usr/bin/env bash
set -Eeu

echo_versioner_env_vars()
{
  local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
  echo COMMIT_SHA="${sha}"

  docker run --rm cyberdojo/versioner:latest

  echo CYBER_DOJO_SAVER_SHA="${sha}"
  echo CYBER_DOJO_SAVER_TAG="${sha:0:7}"

  echo CYBER_DOJO_SAVER_CLIENT_IMAGE=cyberdojo/saver-client

  echo CYBER_DOJO_SAVER_SERVER_USER=saver
  echo CYBER_DOJO_SAVER_CLIENT_USER=nobody

  echo CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME=test_saver_server
  echo CYBER_DOJO_SAVER_CLIENT_CONTAINER_NAME=test_saver_client

  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_SAVER_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/saver
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit 42
  fi
}

containers_down()
{
  docker compose down --remove-orphans --volumes
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent}" is not installed
      exit 42
    fi
  done
}

installed()
{
  local -r dependent="${1}"
  if hash "${dependent}" 2> /dev/null; then
    true
  else
    false
  fi
}

copy_in_saver_test_data()
{
  local -r TEST_DATA_DIR="${ROOT_DIR}/test/server/data"
  local -r CID="${CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME}"
  # You cannot docker cp to a tmpfs, so tar-piping...
  tar --no-xattrs -c -C "${TEST_DATA_DIR}/cyber-dojo" - . | docker exec -i "${CID}" tar x -C /cyber-dojo

  local -r tar_files=(
    almost_full_group.v0.AWCQdE.tgz
    almost_full_group.v1.X9UunP.tgz
    almost_full_group.v2.U8Tt6y.tgz
    rG63fy.tgz
  )
  for tar_file in ${tar_files[*]}; do
    docker exec -i "${CID}" tar -zxf - -C / < "${TEST_DATA_DIR}/${tar_file}"
  done
}
