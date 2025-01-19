#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client}

    Options:
      server  - build the server image (local only)
      client  - build the client image (local and CI workflow)

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server')
      ;;
    'client')
      ;;
    '')
      show_help
      stderr "no argument - must be 'client' or 'server'"
      exit 42
      ;;
    *)
      show_help
      stderr "argument is '${1:-}' - must be 'client' or 'server'"
      exit 42
  esac
}

build_image()
{
  check_args "$@"
  local -r type="${1}"
  exit_non_zero_unless_installed docker
  export $(echo_versioner_env_vars)

  containers_down
  remove_old_images

  docker compose build server
  if [ "${type}" == 'client' ]; then
    docker compose build client
  fi

  local -r image_name="${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"
  local -r sha_in_image=$(docker run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${SHA}')
  if [ "${COMMIT_SHA}" != "${sha_in_image}" ]; then
    echo "ERROR: unexpected env-var inside image ${image_name}"
    echo "expected: 'SHA=${COMMIT_SHA}'"
    echo "  actual: 'SHA=${sha_in_image}'"
    exit 42
  fi

  if [ "${type}" == 'server' ]; then
    # Create latest tag for image build cache
    docker tag "${image_name}" "${CYBER_DOJO_SAVER_IMAGE}:latest"
    # Tag image-name for local development where savers name comes from echo-versioner-env-vars
    docker tag "${image_name}" "${CYBER_DOJO_SAVER_IMAGE}:latest"
    echo "CYBER_DOJO_SAVER_SHA=${CYBER_DOJO_SAVER_SHA}"
    echo "CYBER_DOJO_SAVER_TAG=${CYBER_DOJO_SAVER_TAG}"
    echo "${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"
  fi
}

build_image "$@"