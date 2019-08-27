require_relative 'hex_mini_test'
require_relative '../src/saver'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def saver
    @saver ||= Saver.new
  end

end
