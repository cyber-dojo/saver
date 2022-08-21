#!/bin/bash -Eeu

pushd "${ROOT_DIR}/scripts"
source "./config.sh"
source "./echo_versioner_env_vars.sh"
source "./kosli_echo_env_vars.sh"
source "./kosli_fingerprint.sh"
popd

# - - - - - - - - - - - - - - - - - - -
kosli_approve_deployment()
{
  docker pull $(server_image):$(image_tag)
	docker run \
    --env MERKELY_COMMAND=approve_deployment \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
    --env MERKELY_OLDEST_SRC_COMMITISH=origin/production \
    --env MERKELY_NEWEST_SRC_COMMITISH=${COMMIT_SHA} \
    --env MERKELY_DESCRIPTION="Approval created in Github Actions pipeline" \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
    --volume ${ROOT_DIR}:/src \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    ${MERKELY_CHANGE}

  # For debugging
  git log --graph --full-history --all --color --date=short --pretty=format:"%Cred%x09%h %Creset%ad%Cblue%d %Creset %s %C(bold)(%an)%Creset" | head -n 30
  # Update git tracking branch
  git checkout --track origin/production
  git merge --ff-only ${COMMIT_SHA}
  git push origin production
}

# - - - - - - - - - - - - - - - - - - -
export $(echo_versioner_env_vars)
export $(kosli_echo_env_vars)
kosli_approve_deployment