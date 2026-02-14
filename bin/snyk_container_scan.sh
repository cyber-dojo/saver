#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)

readonly SARIF_FILENAME=${SARIF_FILENAME:-snyk.container.scan.json}
readonly SNYK_LOG_FILENAME="${ROOT_DIR}/snyk.log"

function image_name()
{
  if [ "${IMAGE_NAME:-}" == '' ]; then
    echo "${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"
  else 
    echo "${IMAGE_NAME}"
  fi
}

function sarif_file_exists()
{
  if [ -f "${ROOT_DIR}/${SARIF_FILENAME}" ]; then
    echo true
  else 
    echo false
  fi
}

exit_non_zero_unless_installed snyk

rm "${ROOT_DIR}/${SARIF_FILENAME}" || true

set +e
snyk container test "$(image_name)" -debug \
  --policy-path="${ROOT_DIR}/.snyk" \
  --sarif \
  --sarif-file-output="${ROOT_DIR}/${SARIF_FILENAME}" \
  &> "${SNYK_LOG_FILENAME}"
STATUS=$?
set -e

if grep Forbidden "${SNYK_LOG_FILENAME}" ; then
  cat "${SNYK_LOG_FILENAME}"
  echo
  echo '============================================='
  echo ERROR: Snyk log contains the word 'Forbidden'
  echo "Sarif file exists?: $(sarif_file_exists)"
  echo "Snyk exit status: ${STATUS}"
  echo '============================================='
  echo
  STATUS=42
else
  echo "Snyk exit status: ${STATUS}"
  echo "Sarif file exists?: $(sarif_file_exists)"
fi

if [ "$(sarif_file_exists)" == 'true' ]; then 
  echo
  jq . "${ROOT_DIR}/${SARIF_FILENAME}"
fi

exit "${STATUS}"
