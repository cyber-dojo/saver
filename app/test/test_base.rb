# frozen_string_literal: true
require_relative 'id58_test_base'
require_relative 'doubles/disk_fake'
require_relative 'doubles/rack_request_stub'
require_relative 'doubles/random_stub'
require_relative 'doubles/time_stub'
require_relative 'external/custom_start_points'
require_relative 'require_source'
require_source 'externals'

class TestBase < Id58TestBase

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
  end

  def custom_start_points
    External::CustomStartPoints.new
  end

  def disk
    externals.disk
  end

  def prober
    externals.prober
  end

  def random
    externals.random
  end

  def time
    externals.time
  end

  # - - - - - - - - - - - - - - - - -

  def dir_exists_command(key)
    disk.dir_exists_command(key)
  end

  def dir_make_command(key)
    disk.dir_make_command(key)
  end

  def file_create_command(key, value)
    disk.file_create_command(key, value)
  end

  def file_append_command(key, value)
    disk.file_append_command(key, value)
  end

  def file_read_command(key)
    disk.file_read_command(key)
  end

  # - - - - - - - - - - - - - - - - -
  # Disk and DiskFake dual-contract tests

  def self.disk_tests(hex_suffix, *lines, &block)
    test(hex_suffix+'0', *lines) do
      self.instance_eval(&block)
    end
    test(hex_suffix+'1', *lines) do
      self.externals.instance_eval { @disk = DiskFake.new }
      self.instance_eval(&block)
    end
  end

end
