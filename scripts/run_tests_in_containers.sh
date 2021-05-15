#!/bin/bash

source "${SCRIPTS_DIR}/copy_in_saver_test_data.sh"

readonly my_name=saver

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_tests()
{
  # Getting coverage data
  # - - - - - - - - - - -
  # I would like to do this in docker-compose.yml
  #
  # saver:
  #  volume:
  #    ./tmp:/app/tmp:rw
  #
  # and write the coverage off /app/tmp thus avoiding
  # copying the coverage out of the container.
  #
  # This works locally, but not on the CircleCI pipeline
  # which runs as the ubuntu user, and does not have
  # permission to run this (before docker-compose up):
  #   $ chown -R 19663:65533 ./tmp
  # See app/config/up.sh
  #
  # So coverage data is being written to /tmp inside the container
  # and docker-compose.yml has a tmpfs: /tmp
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out.

  copy_in_saver_test_data

  local -r user="${1}"
  local -r type="${2}" # client|server
  local -r container_coverage_root_dir="/tmp/${type}"
  if [ "${type}" == server ]; then
    local -r cid=$(server_container)
  fi
  if [ "${type}" == client ]; then
    local -r cid=$(client_container)
  fi

  echo
  echo "Running ${type} tests"
  echo

  set +e
  docker exec \
    --user "${user}" \
    --env COVERAGE_ROOT=${container_coverage_root_dir} \
    "${cid}" \
      sh -c "/app/test/config/run.sh ${@:3}"
  local status=$?
  set -e

  if [ "${status}" == 255 ]; then
    exit 42 # ^C
  fi

  local host_coverage_root_dir="${ROOT_DIR}/tmp/coverage"
  mkdir -p "${host_coverage_root_dir}"
  rm -rf "${host_coverage_root_dir}/*"

  docker exec "${cid}" \
    tar Ccf \
      "$(dirname "${container_coverage_root_dir}")" \
      - "$(basename "${container_coverage_root_dir}")" \
        | tar Cxf "${host_coverage_root_dir}/" -

  echo "Copied statement coverage files to ${host_coverage_root_dir}/${type}"
  cat "${host_coverage_root_dir}/${type}/done.txt"
  echo

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
    echo "$(server_container): status = ${server_status}"
    echo "$(client_container): status = ${client_status}"
    echo
    return 1
  fi
}

