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

end
