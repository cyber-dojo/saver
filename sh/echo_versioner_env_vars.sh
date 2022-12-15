#!/usr/bin/env bash
set -Eeu

echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
}
