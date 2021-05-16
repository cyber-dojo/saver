#!/bin/bash

source "${SCRIPTS_DIR}/copy_in_saver_test_data.sh"

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
      sh -c "/app/test/config/run.sh ${TEST_LOG} ${*:4}"
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

  echo "Coverage dir: ${HOST_COVERAGE_DIR}/${type}"
  if [ "${status}" == 0 ]; then
    echo "Test status: PASSED"
  else
    echo "Test status: FAILED"
  fi
  echo

  return ${status}
}
