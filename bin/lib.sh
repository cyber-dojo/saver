
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
    exit_non_zero
  fi
}

exit_non_zero()
{
  kill -INT $$
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
      exit_non_zero
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
    exit_non_zero
  fi
  echo "${STRIPPED}"
}
