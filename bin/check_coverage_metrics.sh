#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client}

    Check test coverage metrics for tests run from inside the client or server container only

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server' | 'client')
      ;;
    '')
      show_help
      stderr "no argument - must be 'client' or 'server'"
      exit 42
      ;;
    *)
      show_help
      stderr "argument is '${1:-}' - must be 'client' or 'server'"
      exit 42
  esac
}

check_coverage()
{
  check_args "$@"
  export $(echo_versioner_env_vars)

  local -r TYPE="${1}"           # {server|client}
  local -r TEST_LOG=test.log
  local -r HOST_TEST_DIR="${ROOT_DIR}/test/${TYPE}"
  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}"  # where report json files have been written to
  local -r CONTAINER_TMP_DIR=/tmp

  exit_non_zero_unless_file_exists "${HOST_TEST_DIR}/config/check_metrics.rb"           # evaluator
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage_metrics.json"          # data from test run
  exit_non_zero_unless_file_exists "${HOST_TEST_DIR}/config/coverage_metrics_limits.rb" # metric limits

  set +e
  docker run \
    --read-only \
    --rm \
    --entrypoint="" \
    --volume ${HOST_TEST_DIR}/config/check_metrics.rb:${CONTAINER_TMP_DIR}/check_metrics.rb:ro \
    --volume ${HOST_REPORTS_DIR}/coverage_metrics.json:${CONTAINER_TMP_DIR}/coverage_metrics.json:ro \
    --volume ${HOST_TEST_DIR}/config/coverage_metrics_limits.rb:${CONTAINER_TMP_DIR}/coverage_metrics_limits.rb:ro \
      "${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}" \
        sh -c "ruby ${CONTAINER_TMP_DIR}/check_metrics.rb ${CONTAINER_TMP_DIR}/coverage_metrics.json coverage_metrics_limits" \
        | tee -a "${HOST_REPORTS_DIR}/${TEST_LOG}"

  local -r STATUS=${PIPESTATUS[0]}
  set -e

  echo "${TYPE} coverage metrics status == ${STATUS}"
  echo
  return "${STATUS}"
}

check_coverage "$@"
