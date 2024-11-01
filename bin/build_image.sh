#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pushd "${ROOT_DIR}/bin"
source "./config.sh"
source "./images_build.sh"
source "./images_check_sha_env_var.sh"
source "./images_remove_old.sh"
source "./images_tag_latest.sh"
source "./lib.sh"
popd

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export $(echo_versioner_env_vars)
exit_non_zero_unless_installed docker

images_build
images_check_sha_env_var
images_tag_latest
images_remove_old
echo
echo "echo CYBER_DOJO_SAVER_SHA=$(image_sha)"
echo "echo CYBER_DOJO_SAVER_TAG=$(image_tag)"
echo
