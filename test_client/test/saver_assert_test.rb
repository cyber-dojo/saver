require_relative 'test_base'
require_relative '../src/saver_assert'

class SaverAssertTest < TestBase

  def self.hex_prefix
    'A27'
  end

  include SaverAssert

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CB1',
  'saver_assert(false) raises SaverException' do
    assert_raises(SaverException) {
      saver_assert(false)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CB2',
  'saver_assert_true() does not raise' do
    saver_assert(true)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '968',
  'saver_assert_equal(arg,arg) does not raise' do
    saver_assert_equal([true,true], [true,true])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '967',
  'saver_assert_equal(arg,!arg) raises SaverException' do
    error = assert_raises(SaverException) do
      saver_assert_equal([true,true], [true,false])
    end
    expected = 'expected:[true, false],actual:[true, true]'
    assert_equal expected, error.message
  end

end
