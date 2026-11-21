#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

# The server tests, run without the server image: in the runtime, the
# Dockerfile's base stage (Ruby, its gems, the OS and the saver user, with no
# source), as docker-compose.bare.yml lays it over docker-compose.yml. Then
# bin/run_tests.sh and the two metrics checks run as they do for the image.
# The runtime the tests ran in is saved to reports/server/runtime_versions.txt
# (see bin/runtime_versions.sh).

readonly LOCAL_RUNTIME_IMAGE=saver-runtime:local

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} [ID...]

    Runs the server tests, then checks their test and coverage metrics, in
    the runtime: the image named by CYBER_DOJO_SAVER_RUNTIME_IMAGE, or else
    one built here with docker build --target base (${LOCAL_RUNTIME_IMAGE}).
    Writes reports/server, as bin/run_tests.sh server does, and
    reports/server/runtime_versions.txt.

    Options:
       -h     Show this help
       ID...  Only run tests matching these identifiers (no metrics checks)

    Example:
       ${MY_NAME}
       CYBER_DOJO_SAVER_RUNTIME_IMAGE=saver-runtime:ab12cd3 ${MY_NAME} Lw2Hy5

EOF
}

# The runtime image: the one given, or one built from the Dockerfile's base.
runtime_image()
{
  if [ -n "${CYBER_DOJO_SAVER_RUNTIME_IMAGE:-}" ]; then
    echo "${CYBER_DOJO_SAVER_RUNTIME_IMAGE}"
  else
    docker build --target base --tag "${LOCAL_RUNTIME_IMAGE}" "${ROOT_DIR}" >&2
    echo "${LOCAL_RUNTIME_IMAGE}"
  fi
}

# The runtime of the server container the tests ran in, which is left up.
save_runtime_versions()
{
  local -r reports_dir="${ROOT_DIR}/reports/server"
  # Short flag: macOS's mkdir has no --parents.
  mkdir -p "${reports_dir}"
  "${ROOT_DIR}/bin/runtime_versions.sh" container "$(service_container server)" \
      > "${reports_dir}/runtime_versions.txt"
  echo "server test runtime is at:"
  echo "${reports_dir}/runtime_versions.txt"
  echo
}

main()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
  esac
  exit_non_zero_unless_installed docker
  CYBER_DOJO_SAVER_RUNTIME_IMAGE="$(runtime_image)"
  export CYBER_DOJO_SAVER_RUNTIME_IMAGE
  export COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml:${ROOT_DIR}/docker-compose.bare.yml"
  # The metrics checks run their ruby in the runtime too, not in the image.
  export CYBER_DOJO_SAVER_METRICS_IMAGE="${CYBER_DOJO_SAVER_RUNTIME_IMAGE}"

  # No earlier run's reports may stand in for this run's.
  rm -rf "${ROOT_DIR}/reports/server"
  local status=0
  "${ROOT_DIR}/bin/run_tests.sh" server "$@" || status=1
  save_runtime_versions
  if [ "$#" == 0 ]; then
    "${ROOT_DIR}/bin/check_test_metrics.sh" server || status=1
    "${ROOT_DIR}/bin/check_coverage_metrics.sh" server || status=1
  fi
  return "${status}"
}

main "$@"
