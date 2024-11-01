#!/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PORT="${CYBER_DOJO_SAVER_CLIENT_PORT}"

puma \
  --port=${PORT} \
  --config=${MY_DIR}/puma.rb
