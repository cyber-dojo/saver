#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pushd "${ROOT_DIR}/sh"

source "./on_ci_publish_images.sh"
source "./kosli_trails.sh"
source "./echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

on_ci_kosli_begin_trail

./build.sh
on_ci_publish_images
on_ci_kosli_attest_artifact

./up.sh
./wait.sh
set -x
./test.sh "$@"
on_ci_kosli_attest_coverage_evidence
on_ci_kosli_attest_snyk_scan_evidence
on_ci_kosli_assert_artifact
on_ci_publish_images latest

popd
