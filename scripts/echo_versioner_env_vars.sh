#!/bin/bash -Eeu

echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
}
