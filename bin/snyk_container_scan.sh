#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)

function image_name()
{
  if [ "${IMAGE_NAME:-}" == '' ]; then
    echo "${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"
  else 
    echo "${IMAGE_NAME}"
  fi
}

readonly SARIF_FILENAME=${SARIF_FILENAME:-snyk.container.scan.json}
readonly SNYK_LOG_FILENAME="${ROOT_DIR}/snyk.log"

exit_non_zero_unless_installed snyk

set +e
snyk container test "$(image_name)" -debug \
  --policy-path="${ROOT_DIR}/.snyk" \
  --sarif \
  --sarif-file-output="${ROOT_DIR}/${SARIF_FILENAME}" \
  | tee "${SNYK_LOG_FILENAME}"
STATUS="${PIPESTATUS[0]}"
set -e

if [ grep Forbidden "${SNYK_LOG_FILENAME}" ]; then
  cat "${SNYK_LOG_FILENAME}"
  echo
  echo '============================================='
  echo ERROR: Snyk log contains the word 'Forbidden'
  echo '============================================='
  echo
  exit 42
fi

exit "${STATUS}"
