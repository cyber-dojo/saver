#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/config.sh"
source "${SCRIPTS_DIR}/echo_versioner_env_vars.sh"
source "${SCRIPTS_DIR}/merkely_echo_env_vars.sh"
source "${SCRIPTS_DIR}/merkely_fingerprint.sh"

# - - - - - - - - - - - - - - - - - - -
merkely_approve_deployment()
{
  docker pull $(server_image):$(image_tag)
	docker run \
    --env MERKELY_COMMAND=approve_deployment \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_OLDEST_SRC_COMMITISH=origin/production \
    --env MERKELY_NEWEST_SRC_COMMITISH=${COMMIT_SHA} \
    --env MERKELY_DESCRIPTION="Approval created in CircleCI" \
    --env MERKELY_SRC_REPO_ROOT=${ROOT_DIR} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
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
export $(merkely_echo_env_vars)
merkely_approve_deployment