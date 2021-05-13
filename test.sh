#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/copy_in_saver_test_data.sh"
source "${SCRIPTS_DIR}/exit_zero_if_show_help.sh"
source "${SCRIPTS_DIR}/exit_non_zero_unless_installed.sh"
source "${SCRIPTS_DIR}/run_tests_in_containers.sh"

source "${SCRIPTS_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

exit_zero_if_show_help "$@"
exit_non_zero_unless_installed docker docker-compose
reset_dirs_inside_containers
copy_in_saver_test_data
run_tests_in_containers "$@"
