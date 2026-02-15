#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)

readonly SARIF_FILENAME=${SARIF_FILENAME:-snyk.container.scan.json}
readonly SNYK_LOG_FILENAME="${ROOT_DIR}/snyk.log"

function echo_image_name()
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
    return 0 # true
  else 
    return 1 # false
  fi
}

function fail_if_log_contains()
{
  local -r filename="${1}"
  local -r find="${2}"
  if grep "${find}" "${filename}" ; then
    cat "${filename}"
    echo
    echo ERROR: ${filename} contains ${find}
    echo
    EXIT_STATUS=42
  fi
}

exit_non_zero_unless_installed snyk jq

rm "${ROOT_DIR}/${SARIF_FILENAME}" &> /dev/null || true

set +e

snyk container test "$(echo_image_name)" -debug \
  --policy-path="${ROOT_DIR}/.snyk" \
  --sarif \
  --sarif-file-output="${ROOT_DIR}/${SARIF_FILENAME}" \
  > "${SNYK_LOG_FILENAME}.stdout" \
 2> "${SNYK_LOG_FILENAME}.stderr" \

SNYK_STATUS=$?

set -e

EXIT_STATUS="${SNYK_STATUS}"

fail_if_log_contains "${SNYK_LOG_FILENAME}.stdout" Forbidden
fail_if_log_contains "${SNYK_LOG_FILENAME}.stderr" Forbidden

fail_if_log_contains "${SNYK_LOG_FILENAME}.stdout" 'Authentication error'
fail_if_log_contains "${SNYK_LOG_FILENAME}.stderr" 'Authentication error'

echo "Snyk exit status: ${SNYK_STATUS}"

echo -n "Sarif file exists?: "
if sarif_file_exists ; then 
  echo true
  jq . "${ROOT_DIR}/${SARIF_FILENAME}"
else
  echo false
fi

exit "${EXIT_STATUS}"
