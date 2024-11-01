#!/bin/bash
set -Eeu

export ROOT_DIR="$(git rev-parse --show-toplevel)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
source "${SH_DIR}/lib.sh"
export $(echo_versioner_env_vars)

run_tests_with_coverage()
{
  exit_code=0
  "${SH_DIR}/up.sh"
  "${SH_DIR}/wait.sh"
  "${SH_DIR}/test.sh" "$@" || exit_code=$?
  #write_coverage_json
  return ${exit_code}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_tests_with_coverage "$@"
fi
