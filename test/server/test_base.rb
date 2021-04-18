# frozen_string_literal: true
require_relative 'hex_mini_test'
require_relative '../src/externals'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
  end

  def saver
    externals.saver
  end

  def dir_exists_command(key)
    saver.dir_exists_command(key)
  end

  def dir_make_command(key)
    saver.dir_make_command(key)
  end

  def file_create_command(key, value)
    saver.file_create_command(key, value)
  end

  def file_append_command(key, value)
    saver.file_append_command(key, value)
  end

  def file_read_command(key)
    saver.file_read_command(key)
  end

end
