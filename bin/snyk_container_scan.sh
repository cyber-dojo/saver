#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)

readonly IMAGE_NAME="${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"

snyk container test "${IMAGE_NAME}" \
  --policy-path="${ROOT_DIR}/.snyk" \
  --sarif \
  --sarif-file-output="${ROOT_DIR}/snyk.container.scan.json"
