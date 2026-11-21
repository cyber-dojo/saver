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
\$stdout.sync = true
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

mkdir -p ${COVERAGE_ROOT}

set +e
export RUBYOPT='-W2 --enable-frozen-string-literal'
ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee ${COVERAGE_ROOT}/${TEST_LOG}
STATUS=${PIPESTATUS[0]}
set -e

# Path coverage is held to only on a whole, passing run: a run of chosen test
# IDs leaves paths untaken trivially, and failing tests' coverage says nothing.
# It fails when any path is untaken or any method has more paths than the
# max_paths coverage.rb sets.
readonly PATHS_CHECK="
report = JSON.parse(File.read(ARGV[0]))
puts PathCoverage::WaysTotals.lines(report)
exit(PathCoverage::WaysTotals.failed?(report) ? 1 : 0)"

if [ "${STATUS}" = 0 ] && [ "${#TEST_ARGS[@]}" = 0 ]; then
  set +e
  ruby -r json -r path_coverage/ways_totals -e "${PATHS_CHECK}" \
    "${COVERAGE_ROOT}/paths/path_coverage.json" 2>&1 \
    | tee -a "${COVERAGE_ROOT}/${TEST_LOG}" # BusyBox tee has no --append
  STATUS=${PIPESTATUS[0]}
  set -e
fi

exit "${STATUS}"
