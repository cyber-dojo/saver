#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${ROOT_DIR}/sh/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

pushd "${ROOT_DIR}/sh"

source "./on_ci_publish_images.sh"
source "./kosli.sh"

on_ci_kosli_declare_pipeline

./build.sh
on_ci_publish_images
on_ci_kosli_report_artifact_creation

./up.sh
./wait.sh
./test.sh "$@"
on_ci_kosli_report_coverage_evidence
on_ci_kosli_assert_artifact

popd
