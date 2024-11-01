#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

readonly IMAGE_NAME="${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"

snyk code test \
  --sarif \
  --sarif-file-output="${ROOT_DIR}/snyk.code.scan.json" \
  --policy-path="${ROOT_DIR}/.snyk"

