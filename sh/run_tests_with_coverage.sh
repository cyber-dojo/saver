#!/bin/bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pushd "${ROOT_DIR}/sh"

source "./echo_versioner_env_vars.sh"
source "./lib.sh"
export $(echo_versioner_env_vars)

if ! on_ci; then
  ./build.sh
fi
./up.sh
./wait.sh
./test.sh "$@"
write_coverage_json

popd
