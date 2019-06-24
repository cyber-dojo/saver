#!/bin/bash
set -e

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - -

curl_cmd()
{
  local -r port="${1}"
  local -r path="${2}"
  local -r cmd="curl --output /dev/null --silent --fail --data {} -X GET http://${IP_ADDRESS}:${port}/${path}"
  echo "${cmd}"
}

# - - - - - - - - - - - - - - - - - - - -

wait_until_ready()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r max_tries=20
  echo -n "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    echo -n '.'
    if $(curl_cmd ${port} ready?) ; then
      echo 'OK'
      return
    else
      sleep 0.1
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after ${max_tries} tries"
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

wait_till_up()
{
  local name="${1}"
  local n=20
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${name}$ ; then
      return
    else
      sleep 0.1
    fi
  done
  echo "${name} not up after ${max_tries} tries"
  docker logs "${name}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - -

exit_unless_clean()
{
  local -r name="${1}"
  local -r docker_log=$(docker logs "${name}")
  local -r line_count=$(echo -n "${docker_log}" | grep -c '^')
  echo -n "Checking ${name} started cleanly..."
  if [ "${line_count}" == '3' ]; then
    echo 'OK'
  else
    echo 'FAIL'
    echo_docker_log "${name}" "${docker_log}"
    exit 1
  fi
}

# - - - - - - - - - - - - - - - - - - - -

echo_docker_log()
{
  local -r name="${1}"
  local -r docker_log="${2}"
  echo "[docker logs ${name}]"
  echo "<docker_log>"
  echo "${docker_log}"
  echo "</docker_log>"
}

# - - - - - - - - - - - - - - - - - - - -

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_until_ready  "test-saver-server" 4537
exit_unless_clean "test-saver-server"

wait_till_up "test-saver-client"
wait_till_up "test-saver-starter"
