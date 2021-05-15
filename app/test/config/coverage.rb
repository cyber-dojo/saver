require 'simplecov'
require_relative 'simplecov-json'

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  coverage_dir(ENV['COVERAGE_ROOT'])
  code_tab = ENV['COVERAGE_CODE_TAB_NAME']
  test_tab = ENV['COVERAGE_TEST_TAB_NAME']
  #add_group('debug') { |the| puts(the.filename); false }
  add_group(code_tab) { |the| the.filename.start_with?("/app/source/" ) }
  add_group(test_tab) { |the| the.filename.start_with?("/app/test/") }
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
])
