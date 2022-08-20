#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

on_ci()
{
  [ -n "${CI:-}" ]
}

pushd "${ROOT_DIR}/scripts"

if ! on_ci; then
  echo Not on CI, so not declaring Kosli piepline
else
  ./kosli_declare_pipeline.sh
fi

./build.sh
./up.sh
./wait.sh
./test.sh

if ! on_ci; then
  echo Not on CI, so not pushing image, not logging to Kosli
else
  ./images_push.sh
  ./kosli_log_artifact.sh
  ./kosli_log_evidence.sh
fi

popd