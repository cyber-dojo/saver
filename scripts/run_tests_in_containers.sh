#!/bin/bash

readonly root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly my_name=saver

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_tests()
{
  local coverage_root=/tmp/coverage
  local user="${1}"
  local type="${2}" # client|server
  local test_dir="test/${type}"
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

  # You can't [docker cp] from a tmpfs, so tar-piping coverage out.
  docker exec "${cid}" \
    tar Ccf \
      "$(dirname "${coverage_root}")" \
      - "$(basename "${coverage_root}")" \
        | tar Cxf "${root_dir}/${test_dir}/" -

  echo "Coverage report copied to ${test_dir}/coverage/"
  cat "${root_dir}/${test_dir}/coverage/done.txt"
  return ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

declare server_status=0
declare client_status=0

run_server_tests()
{
  run_tests saver server "${*}"
  server_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_client_tests()
{
  run_tests nobody client "${*}"
  client_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" = server ]; then
  shift
  run_server_tests "$@"
elif [ "$1" = client ]; then
  shift
  run_client_tests "$@"
else
  run_server_tests "$@"
  run_client_tests "$@"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "${server_status}" = "0" ] && [ "${client_status}" = "0" ]; then
  echo '------------------------------------------------------'
  echo 'All passed'
  echo
  exit 0
else
  echo
  echo "test-${my_name}-server: status = ${server_status}"
  echo "test-${my_name}-client: status = ${client_status}"
  echo
  exit 1
fi