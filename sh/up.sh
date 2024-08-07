#!/usr/bin/env bash
set -Eeu

pushd "${ROOT_DIR}/sh"
source "./config.sh"
source "./echo_versioner_env_vars.sh"
source "./exit_non_zero_unless_installed.sh"
popd

# - - - - - - - - - - - - - - - - - - - -
# I would like to specify this size-limited tmpfs volume in
# the docker-compose.yml file:
#
# version: '3.7'
# saver:
#   volumes:
#     - type: tmpfs
#       target: /one_k
#       tmpfs:
#         size: 1k
#
# but CircleCI does not support this yet.
# It currently supports up to 3.2
# So it is done like this:
#
# saver:
#   volumes:
#    - one_k:/one_k:rw

create_space_limited_volume()
{
  docker volume create --driver local \
    --opt type=tmpfs \
    --opt device=tmpfs \
    --opt o=size=1k \
    one_k \
      > /dev/null
}

# - - - - - - - - - - - - - - - - - - - -
service_up()
{
  local -r service_name="${1}"
  echo
  docker compose \
    up \
    --detach \
    "${service_name}"
}

# - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  echo
  docker compose \
    down \
    --remove-orphans \
    --volumes
}

# - - - - - - - - - - - - - - - - - - - -
containers_up()
{
  create_space_limited_volume

  service_up $(server_name)
  service_up $(client_name)
}

# - - - - - - - - - - - - - - - - - - - -
export $(echo_versioner_env_vars)
exit_non_zero_unless_installed docker
containers_down
containers_up
