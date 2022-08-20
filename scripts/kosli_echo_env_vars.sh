#!/bin/bash -Eeu

kosli_echo_env_vars()
{
  echo MERKELY_CHANGE=merkely/change:latest
  echo MERKELY_OWNER=cyber-dojo
  echo MERKELY_PIPELINE=saver

  echo CI_BUILD_NUM=${GITHUB_RUN_NUMBER}
  echo CI_BUILD_URL=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}
}
