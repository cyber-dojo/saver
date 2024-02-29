#!/bin/bash
set -Eeu

#export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ROOT_DIR="$(git rev-parse --show-toplevel)"
export SH_DIR="${ROOT_DIR}/sh"

#pushd "${ROOT_DIR}/sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
source "${SH_DIR}/lib.sh"
export $(echo_versioner_env_vars)

run_tests_with_coverage()
{
  #if ! on_ci; then
  #  ./build.sh
  #fi
  exit_code=0
  "${SH_DIR}/up.sh"
  "${SH_DIR}/wait.sh"
  "${SH_DIR}/test.sh" "$@" || exit_code=$?
  write_coverage_json
  return ${exit_code}

  #popd
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_tests_with_coverage "$@"
fi
