# frozen_string_literal: true
require_relative 'id58_test_base'
require_relative 'doubles/random_stub'
require_relative 'doubles/time_stub'
require_relative 'helpers/disk'
require_relative 'helpers/externals'
require_relative 'helpers/model'
require_relative 'helpers/rack'
require_relative 'capture_stdout_stderr'
require 'json'

class TestBase < Id58TestBase

  def initialize(arg)
    super(arg)
  end

  include CaptureStdoutStderr
  include TestHelpersDisk
  include TestHelpersExternals
  include TestHelpersModel
  include TestHelpersRack

  def self.disk_tests(hex_suffix, *lines, &block)
    test(hex_suffix+'0', *lines) do
      self.instance_eval(&block)
    end
    test(hex_suffix+'1', *lines) do
      self.externals.instance_eval { @disk = DiskFake.new }
      self.instance_eval(&block)
    end
  end

  def self.v_tests(versions, id58_suffix, *lines, &test_block)
    versions.each do |version|
      v_lines = ["<version=#{version}>"] + lines
      test(id58_suffix + version.to_s, *v_lines, &test_block)
    end
  end

end
