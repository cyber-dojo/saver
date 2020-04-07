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

  def exists_command(key)
    saver.exists_command(key)
  end

  def create_command(key)
    saver.create_command(key)
  end

  def write_command(key, value)
    saver.write_command(key, value)
  end

  def append_command(key, value)
    saver.append_command(key, value)
  end

  def read_command(key)
    saver.read_command(key)
  end

end
