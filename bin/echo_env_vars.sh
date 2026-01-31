
echo_env_vars()
{
  # Set env-vars for this repo
  if [[ ! -v COMMIT_SHA ]] ; then
    local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
    echo COMMIT_SHA="${sha}"  # --build-arg
  fi

  # Setup port env-vars in .env file using versioner
  {
    echo "# This file is generated in bin/lib.sh echo_env_vars()"
    echo "CYBER_DOJO_SAVER_CLIENT_PORT=4538"
    docker run --rm cyberdojo/versioner 2> /dev/null | grep PORT
  } > "${ROOT_DIR}/.env"

  # Get identities of all docker-compose.yml dependent services (from versioner)
  docker run --rm cyberdojo/versioner:latest 2> /dev/null

  echo CYBER_DOJO_SAVER_CLIENT_IMAGE=cyberdojo/saver-client

  echo CYBER_DOJO_SAVER_SERVER_USER=saver
  echo CYBER_DOJO_SAVER_CLIENT_USER=nobody

  echo CYBER_DOJO_SAVER_SERVER_CONTAINER_NAME=test_saver_server
  echo CYBER_DOJO_SAVER_CLIENT_CONTAINER_NAME=test_saver_client
  
  # This repo overrides
  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_SAVER_IMAGE=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/saver
  echo CYBER_DOJO_SAVER_SHA="${sha}"
  echo CYBER_DOJO_SAVER_TAG="${sha:0:7}"
}
