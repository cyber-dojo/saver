#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

readonly VERSION="${1}"
export $(echo_versioner_env_vars)
readonly CONTAINER="${CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME}"
readonly USER="${CYBER_DOJO_SAVER_SERVER_USER}"
# TODO: docker command to bring up server
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
echo "Now add the following tar_file to run/lib.sh"
echo
echo "almost_full_group.v${VERSION}.${GID}.tgz"
echo
