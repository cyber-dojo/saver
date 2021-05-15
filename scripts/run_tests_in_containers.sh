#!/bin/bash

source "${SCRIPTS_DIR}/copy_in_saver_test_data.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - -
declare server_status=0
declare client_status=0

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests_in_containers()
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

  if [ "${server_status}" == "0" ] && [ "${client_status}" == "0" ]; then
    echo '------------------------------------------------------'
    echo 'All passed'
    echo
    return 0
  else
    echo
    echo "$(server_container): status = ${server_status}"
    echo "$(client_container): status = ${client_status}"
    echo
    return 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests()
{
  run_tests $(server_user) $(server_container) $(server_name) "${@:-}"
  server_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_client_tests()
{
  run_tests $(client_user) $(client_container) $(client_name) "${@:-}"
  client_status=$?
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
  # Run tests (with branch coverage) inside the container.

  local -r COVERAGE_CODE_TAB_NAME=app
  local -r COVERAGE_TEST_TAB_NAME=test
  local -r CONTAINER_TMP_DIR=/tmp # fs is read-only with tmpfs at /tmp
  local -r CONTAINER_COVERAGE_DIR="/${CONTAINER_TMP_DIR}/${type}"
  local -r TEST_LOG=test.log

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --user "${user}" \
    "${cid}" \
      sh -c "/app/test/config/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${*:4}"
  local status=$?
  set -e

  if [ "${status}" == 255 ]; then
    exit 42 # ^C
  fi

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Extract test-run results and coverage data from the container.
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out

  local HOST_COVERAGE_DIR="${ROOT_DIR}/tmp/coverage"
  mkdir -p "${HOST_COVERAGE_DIR}"
  rm -rf "${HOST_COVERAGE_DIR}/*"

  docker exec \
    "${cid}" \
    tar Ccf \
      "$(dirname "${CONTAINER_COVERAGE_DIR}")" \
      - "$(basename "${CONTAINER_COVERAGE_DIR}")" \
        | tar Cxf "${HOST_COVERAGE_DIR}/" -


  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Process test-run results and coverage data.

  if [ "${type}" == server ]; then
    local -r HOST_TEST_DIR="${ROOT_DIR}/app/test/config"
  fi
  if [ "${type}" == client ]; then
    local -r HOST_TEST_DIR="${ROOT_DIR}/client/test/config"
  fi

  set +e
  docker run \
    --env COVERAGE_CODE_TAB_NAME="${COVERAGE_CODE_TAB_NAME}" \
    --env COVERAGE_TEST_TAB_NAME="${COVERAGE_TEST_TAB_NAME}" \
    --rm \
    --volume ${HOST_COVERAGE_DIR}/${type}/${TEST_LOG}:${CONTAINER_TMP_DIR}/${TEST_LOG}:ro \
    --volume ${HOST_COVERAGE_DIR}/${type}/index.html:${CONTAINER_TMP_DIR}/index.html:ro \
    --volume ${HOST_COVERAGE_DIR}/${type}/coverage.json:${CONTAINER_TMP_DIR}/coverage.json:ro \
    --volume ${HOST_TEST_DIR}/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
      sh -c \
        "ruby /app/check_test_results.rb \
          ${CONTAINER_TMP_DIR}/${TEST_LOG} \
          ${CONTAINER_TMP_DIR}/index.html \
          ${CONTAINER_TMP_DIR}/coverage.json" \
    | tee -a ${HOST_COVERAGE_DIR}/${type}/${TEST_LOG}

  local -r STATUS=${PIPESTATUS[0]}
  set -e

  echo "Coverage dir: ${HOST_COVERAGE_DIR}/${type}"
  echo "Test status: ${STATUS}"
  echo

  return ${STATUS}
}


