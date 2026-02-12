require 'simplecov'
require_relative 'simplecov_formatter_json'

APP_DIR =  ENV['APP_DIR']

SimpleCov.start do
  coverage_dir(ENV['COVERAGE_ROOT'])
  enable_coverage(:branch)
  primary_coverage(:branch)
  filters.clear
  add_filter("test/id58_test_base.rb")
  root(APP_DIR)

  code_tab = ENV['COVERAGE_CODE_TAB_NAME']
  test_tab = ENV['COVERAGE_TEST_TAB_NAME']
  # add_group('debug') { |the| puts(the.filename); false }
  add_group(code_tab) { |the| the.filename.start_with?("#{APP_DIR}/source/") }
  add_group(test_tab) { |the| the.filename.start_with?("#{APP_DIR}/test/") }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
