#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

readonly VERSION="${1}"  # {0|1|2}
# shellcheck disable=SC2046
export $(echo_env_vars)
readonly CONTAINER="${CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME}"
readonly USER="${CYBER_DOJO_SAVER_SERVER_USER}"

# TODO: Need to start a custom-start-points container
docker --log-level=ERROR compose --progress=plain up --no-build --wait --wait-timeout=10 server
docker exec "${CONTAINER}" bash -c "rm -rf /cyber-dojo/*"
readonly GID=$(docker exec --user "${USER}" "${CONTAINER}" bash -c "ruby /saver/test/data/create_almost_full_group.rb ${VERSION}")

readonly SRC_DIR=/cyber-dojo
readonly DST_TGZ_FILENAME="${ROOT_DIR}/test/server/data/almost_full_group.v${VERSION}.${GID}.tgz"

# extract /cyber-dojo from saver server into tgz file
docker exec "${CONTAINER}" \
  tar -zcf - -C $(dirname ${SRC_DIR}) $(basename ${SRC_DIR}) \
    > "${DST_TGZ_FILENAME}"

echo "Filename == ${DST_TGZ_FILENAME}"
echo
echo "Now add the following tar_file to copy_in_saver_test_data() in run/lib.sh"
echo
echo "almost_full_group.v${VERSION}.${GID}.tgz"
echo
