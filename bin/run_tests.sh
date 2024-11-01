#!/bin/bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/echo_versioner_env_vars.sh"
source "${ROOT_DIR}/bin/lib.sh"
export $(echo_versioner_env_vars)

run_tests_with_coverage()
{
  "${ROOT_DIR}/bin/up.sh"
  "${ROOT_DIR}/bin/wait.sh"
  "${ROOT_DIR}/bin/test.sh" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_tests_with_coverage "$@"
fi
