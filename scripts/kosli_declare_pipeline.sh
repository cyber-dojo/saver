#!/bin/bash -Eeu

pushd "${ROOT_DIR}/scripts"
source "./config.sh"
source "./echo_versioner_env_vars.sh"
source "./kosli_echo_env_vars.sh"
source "./kosli_fingerprint.sh"
popd

export $(echo_versioner_env_vars)
export $(kosli_echo_env_vars)

# - - - - - - - - - - - - - - - - - - -
kosli_declare_pipeline()
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

kosli_declare_pipeline https://staging.app.kosli.com
kosli_declare_pipeline https://app.kosli.com