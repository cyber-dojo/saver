require 'simplecov'
require_relative 'simplecov_formatter_json'

APP_DIR =  ENV['APP_DIR']

SimpleCov.start do
  coverage_dir(ENV['COVERAGE_ROOT'])
  enable_coverage(:branch)
  primary_coverage(:branch)
  filters.clear
  root(APP_DIR)
  cover("source/**/*.rb")
  cover { |file| file.project_filename.start_with?("test/") }
  skip("test/id58_test_base.rb")
  skip("source/config/")

  code_tab = ENV['COVERAGE_CODE_TAB_NAME']
  test_tab = ENV['COVERAGE_TEST_TAB_NAME']
  # group('debug') { |path| puts(path.filename); false }
  group(code_tab) { |path| path.filename.start_with?("#{APP_DIR}/source/") }
  group(test_tab) { |path| path.filename.start_with?("#{APP_DIR}/test/") }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CoverageMetricsFormatter,
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
