#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client} [ID...]

    Options:
       server  - only run tests from inside the server
       client  - only run tests from inside the client
       ID...   - only run tests matching these identifiers

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server')
      export TYPE=server
      export USER="${CYBER_DOJO_SAVER_SERVER_USER}"
      export CONTAINER_NAME="${CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME}"
      ;;
    'client')
      export TYPE=client
      export USER="${CYBER_DOJO_SAVER_CLIENT_USER}"
      export CONTAINER_NAME="${CYBER_DOJO_SAVER_CLIENT_CONTAINER_NAME}"
      ;;
    '')
      show_help
      stderr "no argument - must be 'client' or 'server'"
      exit_non_zero
      ;;
    *)
      show_help
      stderr "argument is '${1:-}' - must be 'client' or 'server'"
      exit_non_zero
  esac
}

run_tests_in_container()
{
  echo
  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  local -r CONTAINER_COVERAGE_DIR="/tmp/reports"
  local -r TEST_LOG=test.log

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=code \
    --env COVERAGE_TEST_TAB_NAME=test \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/saver/test/config/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${TYPE} ${*:2}"
  local -r STATUS=$?
  set -e

  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}" # where to tar-pipe files to

  rm -rf "${HOST_REPORTS_DIR}" &> /dev/null || true
  mkdir -p "${HOST_REPORTS_DIR}" &> /dev/null || true

  docker exec --user "${USER}" "${CONTAINER_NAME}" tar Ccf "${CONTAINER_COVERAGE_DIR}" - . \
      | tar Cxf "${HOST_REPORTS_DIR}/" -

  # Check we generated the expected files.
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/${TEST_LOG}"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/index.html"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage_metrics.json"

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

  return "${STATUS}"
}

run_tests()
{
  # shellcheck disable=SC2046
  export $(echo_env_vars)
  check_args "$@"
  exit_non_zero_unless_installed docker
  containers_down
  create_space_limited_volume
  docker --log-level=ERROR compose --progress=plain up --no-build --wait --wait-timeout=10 "${TYPE}"
  echo_warnings "${TYPE}"
  copy_in_saver_test_data
  run_tests_in_container "$@"
}

run_tests "$@"
