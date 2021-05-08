#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
copy_in_saver_test_data()
{
  local -r SRC_PATH="${ROOT_DIR}/app/test/data/cyber-dojo"
  local -r DEST_PATH=/cyber-dojo
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd "${SRC_PATH}" \
    && tar -c . \
    | docker exec -i "$(saver_cid)" tar x -C "${DEST_PATH}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
reset_dirs_inside_containers()
{
  # See docker-compose.yml for tmpfs and external volume
  local DIRS=''
  # /cyber-dojo is a tmpfs
  DIRS="${DIRS} /cyber-dojo/groups/*"
  DIRS="${DIRS} /cyber-dojo/katas/*"
  # /one_k is an external volume
  # See create_space_limited_volume() in scripts/containers_up.sh
  DIRS="${DIRS} /one_k/*"
  # /tmp is a tmpfs
  DIRS="${DIRS} /tmp/cyber-dojo/*"
  docker exec "$(saver_cid)"        bash -c "rm -rf ${DIRS}"
  docker exec "$(saver_client_cid)" bash -c "rm -rf /tmp/*"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
saver_cid()
{
  echo test-saver-server
}

saver_client_cid()
{
  echo test-saver-client
}
