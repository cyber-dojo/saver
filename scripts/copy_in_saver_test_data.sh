#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
copy_in_saver_test_data()
{
  reset_dirs_inside_containers

  local -r TEST_DATA_DIR="${ROOT_DIR}/app/test/data"

  # You cannot docker cp to a tmpfs, so tar-piping...
  cd "${TEST_DATA_DIR}/cyber-dojo" \
    && tar -c . \
    | docker exec -i "$(server_container)" tar x -C /cyber-dojo

  cat "${TEST_DATA_DIR}/almost_full_group.v0.kYJVbK.tgz" \
    | docker exec -i "$(server_container)" tar -zxf - -C /

  cat "${TEST_DATA_DIR}/almost_full_group.v1.X9UunP.tgz" \
    | docker exec -i "$(server_container)" tar -zxf - -C /
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
reset_dirs_inside_containers()
{
  # See docker-compose.yml for tmpfs and external volume
  local DIRS=''
  # /cyber-dojo is a tmpfs
  DIRS="${DIRS} /cyber-dojo/*"
  # /one_k is an external volume
  # See create_space_limited_volume() in scripts/containers_up.sh
  DIRS="${DIRS} /one_k/*"
  # /tmp is a tmpfs
  DIRS="${DIRS} /tmp/cyber-dojo/*"
  docker exec "$(server_container)" bash -c "rm -rf ${DIRS}"
  docker exec "$(client_container)" bash -c "rm -rf /tmp/*"
}

