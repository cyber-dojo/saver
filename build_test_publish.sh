#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${ROOT_DIR}/sh/on_ci_publish_images.sh"
source "${ROOT_DIR}/sh/kosli.sh"
source "${ROOT_DIR}/sh/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

on_ci_kosli_begin_trail

${ROOT_DIR}/sh/build.sh
on_ci_publish_images
on_ci_kosli_attest_artifact

${ROOT_DIR}/sh/up.sh
${ROOT_DIR}/sh/wait.sh
${ROOT_DIR}/sh/test.sh "$@"

on_ci_kosli_attest_coverage_evidence
on_ci_kosli_attest_snyk_scan_evidence
on_ci_kosli_assert_artifact
on_ci_publish_images latest

