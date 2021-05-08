#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
copy_in_saver_test_data()
{
  local -r SAVER_CID="$(saver_cid)"
  local -r SRC_PATH=${ROOT_DIR}/app/test/data/cyber-dojo
  local -r DEST_PATH=/cyber-dojo
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${SAVER_CID} tar x -C ${DEST_PATH}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
reset_dirs_inside_container()
{
  # See docker-compose.yml for tmpfs and external volume
  local -r SAVER_CID="$(saver_cid)"
  local DIRS=''
  # /cyber-dojo is a tmpfs
  DIRS="${DIRS} /cyber-dojo/groups/*"
  DIRS="${DIRS} /cyber-dojo/katas/*"
  # /tmp is a tmpfs
  DIRS="${DIRS} /tmp/cyber-dojo/*"
  # /one_k is an external volume
  # See create_space_limited_volume() in scripts/containers_up.sh
  DIRS="${DIRS} /one_k/*"
  docker exec "${SAVER_CID}" bash -c "rm -rf ${DIRS}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
saver_cid()
{
  docker ps --filter status=running --format '{{.Names}}' | grep "test-saver-server"
}
