#!/bin/bash -Eeu

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME:-}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - -

readonly READY_FILENAME='/tmp/curl-ready-output'

wait_until_ready()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r max_tries=20
  echo -n "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    echo -n '.'
    if ready ${port} ; then
      echo 'OK'
      return
    else
      sleep 0.1
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after ${max_tries} tries"
  if [ -f "${READY_FILENAME}" ]; then
    echo "$(cat "${READY_FILENAME}")"
  fi
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -
ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r curl_cmd="curl --output ${READY_FILENAME} --silent --fail --data {} -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "${READY_FILENAME}"
  if ${curl_cmd} && [ "$(cat "${READY_FILENAME}")" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - -
wait_till_up()
{
  local name="${1}"
  local -r max_tries=20
  for _ in $(seq ${max_tries})
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${name}$ ; then
      return
    else
      sleep 0.1
    fi
  done
  echo "${name} not up after ${max_tries} tries"
  docker logs "${name}"
  exit 42
}

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
  if [ "${log}" != "${stripped}" ]; then
    >&2 echo "SERVICE START-UP WARNING: ${warning}"
  fi
  echo "${stripped}"
}

# - - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local log=$(docker logs "${name}" 2>&1)
  local lines=3
  if [ "${name}" == 'test-saver-exercises' ]; then
    local lines=6
  fi
  if [ "${name}" == 'test-saver-languages' ]; then
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

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

create_space_limited_volume

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

exit_non_zero_unless_healthy saver test-saver-server
exit_unless_clean  test-saver-server

wait_till_up       test-saver-client
