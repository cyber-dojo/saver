#!/bin/bash

readonly my_name=saver

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_tests()
{
  local -r user="${1}"
  local -r type="${2}" # client|server
  local -r container_coverage_root="/app/tmp/coverage/${type}"
  local -r cid=$(docker ps --all --quiet --filter "name=test-${my_name}-${type}")

  echo
  echo "Running ${type} tests"
  echo

  set +e
  docker exec \
    --user "${user}" \
    --env COVERAGE_ROOT=${container_coverage_root} \
    "${cid}" \
      sh -c "/app/test/config/run.sh ${@:3}"
  local status=$?
  set -e

  # done.txt exists if tests finish (^C can exit early)
  local -r host_coverage_root="${ROOT_DIR}/tmp/coverage/${type}"
  local -r done_txt="${host_coverage_root}/done.txt"
  if [ -e "${done_txt}" ]; then
    echo "Coverage dir: ${host_coverage_root}"
    cat "${host_coverage_root}/done.txt"
  fi

  return ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
declare server_status=0
declare client_status=0

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests()
{
  run_tests saver server "${@:-}"
  server_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_client_tests()
{
  run_tests nobody client "${@:-}"
  client_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests_in_containers()
{
  if [ "${1:-}" == server ]; then
    shift
    run_server_tests "$@"
  elif [ "${1:-}" == client ]; then
    shift
    run_client_tests "$@"
  else
    run_server_tests "$@"
    run_client_tests "$@"
  fi

  if [ "${server_status}" == "0" ] && [ "${client_status}" == "0" ]; then
    echo '------------------------------------------------------'
    echo 'All passed'
    echo
    return 0
  else
    echo
    echo "test-${my_name}-server: status = ${server_status}"
    echo "test-${my_name}-client: status = ${client_status}"
    echo
    return 1
  fi
}

