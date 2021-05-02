#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_healthy()
{
  local -r SERVICE_NAME="${1}"
  local -r CONTAINER_NAME="${2}"
  local -r MAX_TRIES=50

  echo
  printf "Waiting until ${SERVICE_NAME} is healthy"
  for _ in $(seq ${MAX_TRIES})
  do
    if healthy "${CONTAINER_NAME}"; then
      echo; echo "${SERVICE_NAME} is healthy."
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo; echo "${SERVICE_NAME} not healthy after ${MAX_TRIES} tries."
  local log=$(docker logs "${CONTAINER_NAME}" 2>&1)
  echo_docker_log "${SERVICE_NAME}" "${log}"
  echo
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
healthy()
{
  docker ps --filter health=healthy --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"
}

# - - - - - - - - - - - - - - - - - - -
strip_known_warning()
{
  local -r log="${1}"
  local -r pattern="${2}"
  local -r warning=$(printf "${log}" | grep --extended-regexp "${pattern}")
  local -r stripped=$(printf "${log}" | grep --invert-match --extended-regexp "${pattern}")
  #if [ "${log}" != "${stripped}" ]; then
  #  >&2 echo "SERVICE START-UP WARNING: ${warning}"
  #fi
  echo "${stripped}"
}

# - - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local log=$(docker logs "${name}" 2>&1)
  if [ "${name}" == test-saver-server ]; then
    local lines=3
  else
    local lines=6
  fi

  local -r mismatched_indent_warning="application(.*): warning: mismatched indentations at 'rescue' with 'begin'"
  log=$(strip_known_warning "${log}" "${mismatched_indent_warning}")

  local -r line_count=$(echo -n "${log}" | grep -c '^')
  echo -n "Checking ${name} started cleanly..."
  if [ "${line_count}" == "${lines}" ]; then
    echo 'OK'
  else
    echo 'FAIL'
    echo "Expecting ${lines} lines"
    echo "   Actual ${line_count} lines"
    echo_docker_log "${name}" "${log}"
    exit 1
  fi
}

# - - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  local -r name="${1}"
  local -r log="${2}"
  echo "[docker logs ${name}]"
  echo "<docker_log>"
  echo "${log}"
  echo "</docker_log>"
}

# - - - - - - - - - - - - - - - - - - - -
# I would like to specify this size-limited tmpfs volume in
# the docker-compose.yml file:
#
# version: '3.7'
# saver:
#   volumes:
#     - type: tmpfs
#       target: /one_k
#       tmpfs:
#         size: 1k
#
# but CircleCI does not support this yet.
# It currently supports up to 3.2

create_space_limited_volume()
{
  docker volume create --driver local \
    --opt type=tmpfs \
    --opt device=tmpfs \
    --opt o=size=1k \
    one_k \
      > /dev/null
}

# - - - - - - - - - - - - - - - - - - - -
service_up()
{
  local -r service_name="${1}"
  echo
  augmented_docker_compose \
    up \
    --detach \
    "${service_name}"
}

# - - - - - - - - - - - - - - - - - - - -
containers_up()
{
  create_space_limited_volume

  service_up custom-start-points
  service_up saver
  service_up saver_client

  exit_non_zero_unless_healthy custom-start-points saver_custom-start-points_1
  exit_unless_clean saver_custom-start-points_1

  exit_non_zero_unless_healthy saver test-saver-server
  exit_unless_clean test-saver-server

  exit_non_zero_unless_healthy saver_client test-saver-client
  exit_unless_clean test-saver-client
}
