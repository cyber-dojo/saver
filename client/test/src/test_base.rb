require_relative 'hex_mini_test'
require_relative '../../src/grouper_service'
require_relative '../../src/starter_service'

class TestBase < HexMiniTest

  def grouper
    GrouperService.new
  end

  def starter
    StarterService.new
  end

end
