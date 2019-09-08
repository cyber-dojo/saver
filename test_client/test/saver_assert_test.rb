require_relative 'test_base'
require_relative '../src/saver_assert'

class SaverAssertTest < TestBase

  def self.hex_prefix
    'A27'
  end

  include SaverAssert

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '968',
  'does not raise if arg1==arg2' do
    saver_assert([true,true], [true,true])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '967',
  'raises SaverException of args != arg2' do
    error = assert_raises(SaverException) do
      saver_assert([true,true], [true,false])
    end
    expected = 'expected:[true, false],actual:[true, true]'
    assert_equal expected, error.message
  end

end
