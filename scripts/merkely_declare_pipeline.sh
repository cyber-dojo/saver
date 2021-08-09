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
merkely_declare_pipeline()
{
  local -r hostname="${1}"

	docker run \
		--env MERKELY_COMMAND=declare_pipeline \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
		--env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
		--rm \
		--volume ${ROOT_DIR}/Merkelypipe.json:/data/Merkelypipe.json \
		${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -

merkely_declare_pipeline https://staging.app.merkely.com
merkely_declare_pipeline https://app.merkely.com