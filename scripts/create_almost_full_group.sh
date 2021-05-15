#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

my_name=saver
type=server
user=saver
server_cid=$(docker ps --all --quiet --filter "name=test-${my_name}-${type}")
version="${1}"

docker exec "${server_cid}" bash -c "rm -rf /cyber-dojo/*"

gid=$(docker exec \
  --user "${user}" \
  "${server_cid}" \
  bash -c "ruby /app/test/data/create_almost_full_group.rb ${version}")

src_dir=/cyber-dojo
dst_tgz_filename="${ROOT_DIR}/app/test/data/almost_full_group.v${version}.${gid}.tgz"

#extract /cyber-dojo from server_cid into tgz file
docker exec ${server_cid} \
  tar -zcf - -C $(dirname ${src_dir}) $(basename ${src_dir}) \
    > "${dst_tgz_filename}"

echo "Filename == ${dst_tgz_filename}"
