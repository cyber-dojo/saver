require 'simplecov'
require 'path_coverage'
require_relative 'simplecov_formatter_json'

APP_DIR =  ENV['APP_DIR']
CODE_TAB = ENV['COVERAGE_CODE_TAB_NAME']
TEST_TAB = ENV['COVERAGE_TEST_TAB_NAME']
CODE_GLOB = 'source/**/*.rb'
TEST_GLOB = 'test/**/*.rb'
TEST_BASE = 'test/id58_test_base.rb'

SimpleCov.start do
  root(APP_DIR)
  coverage_dir(ENV['COVERAGE_ROOT'])
  enable_coverage(:branch)
  primary_coverage(:branch)
  filters.clear
  cover(CODE_GLOB)
  cover { |file| file.project_filename.start_with?("test/") }
  skip(TEST_BASE)
  skip("source/config/")
  # group('debug') { |path| puts(path.filename); false }
  group(CODE_TAB) { |path| path.filename.start_with?("#{APP_DIR}/source/") }
  group(TEST_TAB) { |path| path.filename.start_with?("#{APP_DIR}/test/") }
end

# Covers the same files as SimpleCov above, and prints each path no test took.
# A method with more than 8 paths fails; run.sh checks the report this writes.
PathCoverage.start do
  root(APP_DIR)
  coverage_dir("#{ENV['COVERAGE_ROOT']}/paths")
  report(:gaps, :summary)
  max_paths(8)
  cover(CODE_GLOB)
  cover(TEST_GLOB)
  skip(TEST_BASE)
  skip('source/config/**/*.rb')
  # Coverage tooling and data scripts: run before or after the tests, never by them.
  skip('test/config/**/*.rb')
  skip('test/data/**/*.rb')
  group(CODE_TAB, CODE_GLOB)
  group(TEST_TAB, TEST_GLOB)
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CoverageMetricsFormatter,
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
