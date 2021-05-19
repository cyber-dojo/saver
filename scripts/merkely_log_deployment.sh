#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/config.sh"
source "${SCRIPTS_DIR}/echo_versioner_env_vars.sh"
source "${SCRIPTS_DIR}/merkely_echo_env_vars.sh"
source "${SCRIPTS_DIR}/merkely_fingerprint.sh"

export $(echo_versioner_env_vars)
export $(merkely_echo_env_vars)

# - - - - - - - - - - - - - - - - - - -
merkely_log_deployment()
{
  local -r environment="${1}"
  docker pull $(server_image):$(image_tag)
	docker run \
    --env MERKELY_COMMAND=log_deployment \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_DESCRIPTION="Deployed to ${environment} in circleci pipeline" \
    --env MERKELY_ENVIRONMENT="${environment}" \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_deployment "${1}"