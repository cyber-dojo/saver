#!/bin/bash

readonly my_name=saver

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_tests()
{
  local user="${1}"
  local type="${2}" # client|server
  local coverage_root="/tmp/${type}"
  local cid=$(docker ps --all --quiet --filter "name=test-${my_name}-${type}")

  echo
  echo '======================================'
  echo "Testing: ${type}"

  docker exec \
    --user "${user}" \
    --env COVERAGE_ROOT=${coverage_root} \
    "${cid}" \
      sh -c "/app/test/util/run.sh ${@:3}"

  local status=$?

  local cov_dir="${ROOT_DIR}/coverage"
  echo "Copying statement coverage files to ${cov_dir}/${type}"
  mkdir -p "${cov_dir}"
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out.
  docker exec "${cid}" \
    tar Ccf \
      "$(dirname "${coverage_root}")" \
      - "$(basename "${coverage_root}")" \
        | tar Cxf "${cov_dir}/" -

  cat "${cov_dir}/${type}/done.txt"

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

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

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

