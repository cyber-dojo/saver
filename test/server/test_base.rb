# frozen_string_literal: true

require_relative 'hex_mini_test'
require_relative 'require_source'
require_source 'externals'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
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

end
