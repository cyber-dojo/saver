#!/usr/bin/env bash
set -Eeu

pushd "${ROOT_DIR}/sh"
source "./config.sh"
source "./echo_versioner_env_vars.sh"
source "./exit_non_zero_unless_installed.sh"
source "./exit_zero_if_show_help.sh"
popd

# - - - - - - - - - - - - - - - - - - - - - - - - - -
containers_run_tests()
{
  if [ "${1:-}" == server ]; then
    shift
    run_server_tests "$@"
  elif [ "${1:-}" == client ]; then
    shift
    run_client_tests "$@"
  else
    run_server_tests "$@"
    run_client_tests "$@"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests()
{
  run_tests $(server_user) $(server_container) $(server_name) "${@:-}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_client_tests()
{
  run_tests $(client_user) $(client_container) $(client_name) "${@:-}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  # Getting coverage data
  # - - - - - - - - - - -
  # I would like to do this in docker-compose.yml
  #
  # saver:
  #  volume:
  #    ./tmp:/app/tmp:rw
  #
  # and write the coverage off /app/tmp thus avoiding
  # copying the coverage out of the container.
  #
  # This works locally, but not on the CircleCI pipeline
  # which runs as the ubuntu user, and does not have
  # permission to run this (before docker-compose up):
  #   $ chown -R 19663:65533 ./tmp
  # See app/config/up.sh
  #
  # So coverage data is being written to /tmp inside the container
  # and docker-compose.yml has a tmpfs: /tmp
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out.

  reset_dirs_inside_containers
  copy_in_saver_test_data

  local -r user="${1}"
  local -r cid="${2}"
  local -r type="${3}" # client|server

  echo
  echo "Running ${type} tests"
  echo

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run tests and test-result metrics inside the container.

  local -r CONTAINER_COVERAGE_DIR="/tmp/${type}"

  local -r COVERAGE_CODE_TAB_NAME=app
  local -r COVERAGE_TEST_TAB_NAME=test

  local -r TEST_LOG=test.log

  set +e
  docker exec \
    --env COVERAGE_ROOT=${CONTAINER_COVERAGE_DIR} \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --user "${user}" \
    "${cid}" \
      sh -c "/saver/test/config/run.sh ${TEST_LOG} ${*:4}"
  local status=$?
  set -e

  if [ "${status}" == 255 ]; then
    exit 42 # ^C
  fi

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Extract test-results and metrics data from the container.
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out

  local -r HOST_COVERAGE_DIR="${ROOT_DIR}/tmp/coverage"

  mkdir -p "${HOST_COVERAGE_DIR}"
  rm -rf "${HOST_COVERAGE_DIR}/*"

  docker exec \
    "${cid}" \
    tar Ccf \
      "$(dirname "${CONTAINER_COVERAGE_DIR}")" \
      - "$(basename "${CONTAINER_COVERAGE_DIR}")" \
        | tar Cxf "${HOST_COVERAGE_DIR}/" -

  echo Coverage written to
  echo "${HOST_COVERAGE_DIR}/${type}/index.html"
  if [ "${status}" == 0 ]; then
    echo "Test status: PASSED"
  else
    echo "Test status: FAILED"
  fi
  echo

  return ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
reset_dirs_inside_containers()
{
  # See docker-compose.yml for tmpfs and external volume
  local DIRS=''
  # /cyber-dojo is a tmpfs
  DIRS="${DIRS} /cyber-dojo/*"
  # /one_k is an external volume
  # See create_space_limited_volume() in ./up.sh
  DIRS="${DIRS} /one_k/*"
  # /tmp is a tmpfs
  DIRS="${DIRS} /tmp/cyber-dojo/*"
  docker exec "$(server_container)" bash -c "rm -rf ${DIRS}"
  docker exec "$(client_container)" bash -c "rm -rf /tmp/*"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
copy_in_saver_test_data()
{
  local -r TEST_DATA_DIR="${ROOT_DIR}/test/server/data"

  # You cannot docker cp to a tmpfs, so tar-piping...
  cd "${TEST_DATA_DIR}/cyber-dojo" \
    && tar -c . \
    | docker exec -i "$(server_container)" tar x -C /cyber-dojo

  cat "${TEST_DATA_DIR}/almost_full_group.v0.AWCQdE.tgz" \
    | docker exec -i "$(server_container)" tar -zxf - -C /

  cat "${TEST_DATA_DIR}/almost_full_group.v1.X9UunP.tgz" \
    | docker exec -i "$(server_container)" tar -zxf - -C /

  cat "${TEST_DATA_DIR}/almost_full_group.v2.U8Tt6y.tgz" \
    | docker exec -i "$(server_container)" tar -zxf - -C /

  cat "${TEST_DATA_DIR}/rG63fy.tgz" \
    | docker exec -i "$(server_container)" tar -zxf - -C /
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export $(echo_versioner_env_vars)
exit_zero_if_show_help "$@"
exit_non_zero_unless_installed docker
containers_run_tests "$@"
