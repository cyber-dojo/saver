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
kosli_log_evidence()
{
  local -r hostname="${1}"

	docker run \
    --env MERKELY_COMMAND=log_evidence \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
    --env MERKELY_EVIDENCE_TYPE=branch-coverage \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_DESCRIPTION="server & client branch-coverage reports" \
    --env MERKELY_USER_DATA="$(evidence_json_path)" \
    --env MERKELY_CI_BUILD_URL=${CI_BUILD_URL} \
    --env MERKELY_HOST="${hostname}" \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
    --volume "$(evidence_json_path):$(evidence_json_path)" \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
write_evidence_json()
{
  echo '{ "server": ' > "$(evidence_json_path)"
  cat "${ROOT_DIR}/tmp/coverage/server/coverage.json" >> "$(evidence_json_path)"
  echo ', "client": ' >> "$(evidence_json_path)"
  cat "${ROOT_DIR}/tmp/coverage/client/coverage.json" >> "$(evidence_json_path)"
  echo '}' >> "$(evidence_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
evidence_json_path()
{
  echo "${ROOT_DIR}/tmp/evidence.json"
}

# - - - - - - - - - - - - - - - - - - -

write_evidence_json
kosli_log_evidence https://staging.app.kosli.com
kosli_log_evidence https://app.kosli.com