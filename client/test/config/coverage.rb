require 'simplecov'

SimpleCov.start do
  cov_root = File.expand_path('../..', __dir__)
  root(cov_root)
  coverage_dir(ENV['COVERAGE_ROOT'])
  add_group('code') { |the| the.filename.start_with?("#{cov_root}/source" ) }
  add_group('test') { |the| the.filename.start_with?("#{cov_root}/test") }
end
