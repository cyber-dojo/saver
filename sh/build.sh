#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pushd "${ROOT_DIR}/sh"
source "./augmented_docker_compose.sh"
source "./config.sh"
source "./create_docker_compose_yml.sh"
source "./echo_env_vars.sh"
source "./echo_versioner_env_vars.sh"
source "./exit_non_zero_unless_installed.sh"
source "./images_build.sh"
source "./images_check_sha_env_var.sh"
source "./images_remove_old.sh"
source "./images_tag_latest.sh"
source "./lib.sh"
popd

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export $(echo_versioner_env_vars)
exit_non_zero_unless_installed docker docker-compose
create_docker_compose_yml
images_build
images_check_sha_env_var
images_tag_latest
images_remove_old
echo_env_vars