#!/bin/bash -Eeu

export SERVICE_NAME=saver

export SERVICE_NAME_UPPER=$(echo "${SERVICE_NAME}" | tr '[:lower:]' '[:upper:]')

export COMMIT_SHA="$(echo -n $(cd "${ROOT_DIR}" && git rev-parse HEAD))"

image_sha() { echo -n ${COMMIT_SHA}; }
image_tag() { echo -n ${COMMIT_SHA:0:7}; }

export COMMIT_TAG=$(image_tag)

SERVER_IMAGE="CYBER_DOJO_${SERVICE_NAME_UPPER}_IMAGE" # from cyberdojo/versioner
SERVER_PORT="CYBER_DOJO_${SERVICE_NAME_UPPER}_PORT"   # from cyberdojo/versioner

server_image()     { echo -n "${!SERVER_IMAGE}"; }
server_port()      { echo -n "${!SERVER_PORT}"; }
server_container() { echo -n test_${SERVICE_NAME}_server; }
server_name()      { echo -n server; }
server_user()      { echo -n saver; }
server_context()   { echo -n .; }

client_image()     { echo -n "cyberdojo/${SERVICE_NAME}-client"; }
client_port()      { echo -n 9999; }
client_container() { echo -n test_${SERVICE_NAME}_client; }
client_name()      { echo -n client; }
client_user()      { echo -n nobody; }
client_context()   { echo -n ./client; }

