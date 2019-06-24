require_relative 'hex_mini_test'
require_relative '../src/saver_service'
require_relative '../src/starter'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def saver
    SaverService.new
  end

  def starter
    Starter.new
  end

end
