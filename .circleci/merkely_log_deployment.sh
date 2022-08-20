#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

pushd "${ROOT_DIR}/scripts"
source "./config.sh"
source "./echo_versioner_env_vars.sh"
source "./kosli_echo_env_vars.sh"
source "./kosli_fingerprint.sh"
popd

export $(echo_versioner_env_vars)
export $(kosli_echo_env_vars)

# - - - - - - - - - - - - - - - - - - -
kosli_log_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"

	docker run \
    --env MERKELY_COMMAND=log_deployment \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
    --env MERKELY_DESCRIPTION="Deployed to ${environment} in Github Actions pipeline" \
    --env MERKELY_ENVIRONMENT="${environment}" \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_HOST="${hostname}" \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
docker pull $(server_image):$(image_tag)

readonly ENVIRONMENT="${1}"
readonly HOSTNAME="${2}"
kosli_log_deployment "${ENVIRONMENT}" "${HOSTNAME}"
