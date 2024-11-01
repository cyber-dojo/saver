#!/usr/bin/env bash
set -Eeu

pushd "${ROOT_DIR}/bin"
source "./echo_versioner_env_vars.sh"
popd

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
exit_non_zero_unless_clean()
{
  local -r name="${1}"
  local log=$(docker logs "${name}" 2>&1)

  #if [ "${name}" == saver_custom-start-points_1 ]; then
  #  local -r lines=6
  #else
  local -r lines=8
  #fi

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
    exit 42
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
  exit_non_zero_unless_clean ${CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME}
  exit_non_zero_unless_clean ${CYBER_DOJO_SAVER_CLIENT_CONTAINER_NAME}
}

# - - - - - - - - - - - - - - - - - - - -
export $(echo_versioner_env_vars)
containers_wait
