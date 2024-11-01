#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export COVERAGE_ROOT="${1}" # eg /tmp/coverage
readonly TEST_LOG="${2}"    # eg test.log
readonly TYPE="${3}"        # eg client|server
shift; shift; shift

readonly TEST_FILES=(${MY_DIR}/../*.rb)
readonly TEST_ARGS=(${*})

readonly SCRIPT="
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

export RUBYOPT='-W2'
mkdir -p ${COVERAGE_ROOT}

set +e
ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee ${COVERAGE_ROOT}/${TEST_LOG}
STATUS=${PIPESTATUS[0]}
set -e

exit "${STATUS}"

#ruby "${MY_DIR}/check_test_metrics.rb" "${TEST_LOG}"
