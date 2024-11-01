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

  local -r USER="${1}"
  local -r CONTAINER_NAME="${2}"
  local -r TYPE="${3}" # client|server

  echo
  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  local -r CONTAINER_COVERAGE_DIR="/tmp/reports"
  local -r TEST_LOG=test.log

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=app \
    --env COVERAGE_TEST_TAB_NAME=test \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/saver/test/config/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${TYPE} ${*:4}"
  local STATUS=$?
  set -e

  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}" # where to tar-pipe files to

  rm -rf "${HOST_REPORTS_DIR}" &> /dev/null || true
  mkdir -p "${HOST_REPORTS_DIR}" &> /dev/null || true

  docker exec --user "${USER}" \
    "${CONTAINER_NAME}" \
    tar Ccf "${CONTAINER_COVERAGE_DIR}" - . \
        | tar Cxf "${HOST_REPORTS_DIR}/" -

  # Check we generated the expected files.
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/${TEST_LOG}"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/index.html"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage.json"

  echo "${TYPE} test branch-coverage report is at:"
  echo "${HOST_REPORTS_DIR}/index.html"
  echo
  echo "${TYPE} test status == ${STATUS}"
  echo

  if [ "${STATUS}" != 0 ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}" 2>&1
  fi

  return ${STATUS}
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
