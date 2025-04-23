
echo_base_image()
{
  # This is set to the env-var BASE_IMAGE which is set as a docker compose build --build-arg
  # and used the Dockerfile's 'FROM ${BASE_IMAGE}' statement
  # This BASE_IMAGE abstraction is to facilitate the base_image_update.yml workflow.
  # echo_base_image_via_curl
  echo_base_image_via_code
}

echo_base_image_via_curl()
{
  local -r json="$(curl --fail --silent --request GET https://beta.cyber-dojo.org/saver/base_image)"
  echo "${json}" | jq -r '.base_image'
}

echo_base_image_via_code()
{
  # An alternative echo_base_image for local development, or initial base-image upgrade
  local -r tag=a903598
  local -r digest=12f9997694fbc19acbdc2ac4c3e616ff5896c4e8e7bc5d37a961af2245e5e18d
  echo "cyberdojo/sinatra-base:${tag}@sha256:${digest}"
}

exit_non_zero_if_bad_base_image()
{
  # Called in setup job in .github/workflows/main.yml
  local -r base_image="${1}"
  local -r regex=":[a-z0-9]{7}@sha256:[a-z0-9]{64}$"
  if [[ ${base_image} =~ $regex ]]; then
    echo "PASSED: base_image=${base_image}"
  else
    stderr "base_image=${base_image}"
    stderr "must have a 7-digit short-sha tag and a full 64-digit digest, Eg"
    stderr "  name  : cyberdojo/sinatra-base"
    stderr "  tag   : 559d354"
    stderr "  digest: ddab9080cd0bbd8e976a18bdd01b37b66e47fe83b0db396e65dc3014bad17fd3"
    exit 42
  fi
}

echo_env_vars()
{
  # Set env-vars for this repo
  if [[ ! -v BASE_IMAGE ]] ; then
    echo BASE_IMAGE="$(echo_base_image)"  # --build-arg
  fi
  if [[ ! -v COMMIT_SHA ]] ; then
    local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
    echo COMMIT_SHA="${sha}"  # --build-arg
  fi

  # Setup port env-vars in .env file using versioner
  local -r env_filename="${ROOT_DIR}/.env"
  echo "# This file is generated in bin/lib.sh echo_env_vars()" > "${env_filename}"
  echo "CYBER_DOJO_SAVER_CLIENT_PORT=4538"                     >> "${env_filename}"
  docker run --rm cyberdojo/versioner 2> /dev/null | grep PORT >> "${env_filename}"

  # Get identities of all docker-compose.yml dependent services (from versioner)
  docker run --rm cyberdojo/versioner:latest 2> /dev/null

  echo CYBER_DOJO_SAVER_SHA="${sha}"
  echo CYBER_DOJO_SAVER_TAG="${sha:0:7}"

  echo CYBER_DOJO_SAVER_CLIENT_IMAGE=cyberdojo/saver-client

  echo CYBER_DOJO_SAVER_SERVER_USER=saver
  echo CYBER_DOJO_SAVER_CLIENT_USER=nobody

  echo CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME=test_saver_server
  echo CYBER_DOJO_SAVER_CLIENT_CONTAINER_NAME=test_saver_client

  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_SAVER_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/saver
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit 42
  fi
}

containers_down()
{
  docker --log-level=ERROR compose down --remove-orphans --volumes
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed"
      exit 42
    fi
  done
}

installed()
{
  local -r dependent="${1}"
  if hash "${dependent}" 2> /dev/null; then
    true
  else
    false
  fi
}

create_space_limited_volume()
{
  docker volume create --driver local \
    --opt type=tmpfs \
    --opt device=tmpfs \
    --opt o=size=1k \
    one_k \
      > /dev/null
}

copy_in_saver_test_data()
{
  local -r TEST_DATA_DIR="${ROOT_DIR}/test/server/data"
  local -r CID="${CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME}"
  # You cannot docker cp to a tmpfs, so tar-piping...

  if [ "${CI:-}" == 'true' ]; then
    set -x
  fi

  # In the CI workflow this gives a diagnostic
  #   tar: -: Cannot stat: No such file or directory
  #   tar: Exiting with failure status due to previous errors
  # But it appears to worked as the tests all pass, and when commented out some fail ?!?
  tar --no-xattrs -c -C "${TEST_DATA_DIR}/cyber-dojo" - . | docker exec -i "${CID}" tar x -C /cyber-dojo

  if [ "${CI:-}" == 'true' ]; then
    set +x
  fi

  local -r tar_files=(
    almost_full_group.v0.AWCQdE.tgz
    almost_full_group.v1.X9UunP.tgz
    almost_full_group.v2.U8Tt6y.tgz
    rG63fy.tgz
  )
  for tar_file in ${tar_files[*]}; do
    docker exec -i "${CID}" tar -zxf - -C / < "${TEST_DATA_DIR}/${tar_file}"
  done
}

remove_old_images()
{
  # Tagging images from the commit-sha can build up
  # a very large amount of images over time. Their
  # sheer number can slow things down: eg
  #   o) filtering a [docker image ls]
  #   o) occasional [docker ps -aq | xargs docker image rm]
  # I prefer to remove old images Continuously.
  #
  # Removing old images and not busting the image layer
  # cache requires the latest image is tagged to :latest

  echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep saver)
  remove_all_but_latest "${dil}" "${CYBER_DOJO_SAVER_CLIENT_IMAGE}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_SAVER_IMAGE}"
  remove_all_but_latest "${dil}" cyberdojo/saver
}

remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in $(echo "${docker_image_ls}" | grep "${name}:")
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      docker image rm "${image_name}"
    fi
  done
  docker system prune --force
}

echo_warnings()
{
  local -r SERVICE_NAME="${1}"
  local -r DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)
  # Handle known warnings (eg waiting on Gem upgrade)
  # local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  # DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  if echo "${DOCKER_LOG}" | grep --quiet "warning" ; then
    echo "Warnings in ${SERVICE_NAME} container"
    echo "${DOCKER_LOG}"
  fi
}

strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local -r STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
    exit 42
  fi
  echo "${STRIPPED}"
}
