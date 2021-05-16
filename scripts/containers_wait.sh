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

  if [ "${name}" == saver_custom-start-points_1 ]; then
    local -r lines=6
  else
    local -r lines=8
  fi

  #local -r mismatched_indent_warning="application(.*): warning: mismatched indentations at 'rescue' with 'begin'"
  #log=$(strip_known_warning "${log}" "${mismatched_indent_warning}")

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
containers_wait()
{
  exit_non_zero_unless_healthy custom-start-points saver_custom-start-points_1
  exit_unless_clean saver_custom-start-points_1

  exit_non_zero_unless_healthy $(server_name) $(server_container)
  exit_unless_clean $(server_container)

  exit_non_zero_unless_healthy $(client_name) $(client_container)
  exit_unless_clean $(client_container)
}

