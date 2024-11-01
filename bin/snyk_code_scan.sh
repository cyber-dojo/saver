#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

snyk code test \
  --sarif \
  --sarif-file-output="${ROOT_DIR}/snyk.code.scan.json" \
  --policy-path="${ROOT_DIR}/.snyk"

