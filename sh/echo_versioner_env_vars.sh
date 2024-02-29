#!/usr/bin/env bash
set -Eeu

echo_versioner_env_vars()
{
  local -r sha="$(cd "$(repo_root)" && git rev-parse HEAD)"
  docker run --rm cyberdojo/versioner:latest
  echo CYBER_DOJO_SAVER_SHA="${sha}"
  echo CYBER_DOJO_SAVER_TAG="${sha:0:7}"
}
