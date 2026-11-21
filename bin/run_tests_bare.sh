#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

# The server tests, run without the deployed image: in the bare image, the
# Dockerfile's base stage (Ruby, its gems, the OS packages and the saver user,
# with no source code), as docker-compose.bare.yml lays it over
# docker-compose.yml. Then bin/run_tests.sh and the two metrics checks run as
# they do for the deployed image. The bare image's packages are saved to
# reports/server/bare_image_packages.txt (see bin/image_packages.sh).

readonly LOCAL_BARE_IMAGE=saver-bare-image:local

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} [ID...]

    Runs the server tests, then checks their test and coverage metrics, in
    the bare image: the one named by CYBER_DOJO_SAVER_BARE_IMAGE, or else
    one built here with docker build --target base (${LOCAL_BARE_IMAGE}).
    Writes reports/server, as bin/run_tests.sh server does, and
    reports/server/bare_image_packages.txt.

    Options:
       -h     Show this help
       ID...  Only run tests matching these identifiers (no metrics checks)

    Example:
       ${MY_NAME}
       CYBER_DOJO_SAVER_BARE_IMAGE=saver-bare-image:ab12cd3 ${MY_NAME} Lw2Hy5

EOF
}

# The bare image: the one given, or one built from the Dockerfile's base stage.
bare_image()
{
  if [ -n "${CYBER_DOJO_SAVER_BARE_IMAGE:-}" ]; then
    echo "${CYBER_DOJO_SAVER_BARE_IMAGE}"
  else
    docker build --target base --tag "${LOCAL_BARE_IMAGE}" "${ROOT_DIR}" >&2
    echo "${LOCAL_BARE_IMAGE}"
  fi
}

# The packages of the server container the tests ran in, which is left up.
save_bare_image_packages()
{
  local -r reports_dir="${ROOT_DIR}/reports/server"
  # Short flag: macOS's mkdir has no --parents.
  mkdir -p "${reports_dir}"
  "${ROOT_DIR}/bin/image_packages.sh" container "$(service_container server)" \
      > "${reports_dir}/bare_image_packages.txt"
  echo "server test bare image packages are at:"
  echo "${reports_dir}/bare_image_packages.txt"
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
  CYBER_DOJO_SAVER_BARE_IMAGE="$(bare_image)"
  export CYBER_DOJO_SAVER_BARE_IMAGE
  export COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml:${ROOT_DIR}/docker-compose.bare.yml"
  # The metrics checks run their ruby in the bare image too.
  export CYBER_DOJO_SAVER_METRICS_IMAGE="${CYBER_DOJO_SAVER_BARE_IMAGE}"

  # No earlier run's reports may stand in for this run's.
  rm -rf "${ROOT_DIR}/reports/server"
  local status=0
  "${ROOT_DIR}/bin/run_tests.sh" server "$@" || status=1
  save_bare_image_packages
  if [ "$#" == 0 ]; then
    "${ROOT_DIR}/bin/check_test_metrics.sh" server || status=1
    "${ROOT_DIR}/bin/check_coverage_metrics.sh" server || status=1
  fi
  return "${status}"
}

main "$@"
