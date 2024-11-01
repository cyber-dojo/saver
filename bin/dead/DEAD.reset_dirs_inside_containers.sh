
reset_dirs_inside_containers()
{
  local -r type="${1}"
  # See docker-compose.yml for tmpfs and external volume
  local DIRS=''
  # /cyber-dojo is a tmpfs
  DIRS="${DIRS} /cyber-dojo/*"
  # /one_k is an external volume
  # See create_space_limited_volume() in ./up.sh
  DIRS="${DIRS} /one_k/*"
  # /tmp is a tmpfs
  DIRS="${DIRS} /tmp/cyber-dojo/*"
  docker exec "${CONTAINER_NAME}" bash -c "rm -rf ${DIRS}"
  if [ "${type}" == 'client' ]; then
    docker exec "${CONTAINER_NAME}" bash -c "rm -rf /tmp/*"
  fi
}
