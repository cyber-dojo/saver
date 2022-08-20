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
kosli_log_artifact()
{
  local -r hostname="${1}"

	docker run \
    --env MERKELY_COMMAND=log_artifact \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_ARTIFACT_GIT_COMMIT=${COMMIT_SHA} \
    --env MERKELY_ARTIFACT_GIT_URL=https://github.com/${MERKELY_OWNER}/${MERKELY_PIPELINE}/commit/${COMMIT_SHA} \
    --env MERKELY_CI_BUILD_NUMBER=${CI_BUILD_NUM} \
    --env MERKELY_CI_BUILD_URL=${CI_BUILD_URL} \
    --env MERKELY_HOST="${hostname}" \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -

kosli_log_artifact https://staging.app.kosli.com
kosli_log_artifact https://app.kosli.com