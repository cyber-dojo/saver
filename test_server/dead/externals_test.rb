require_relative 'test_base'

class ExternalsTest < TestBase

  def self.hex_prefix
    '7A9'
  end

  # - - - - - - - - - - - - - - - - -

  test '543',
  'default externals are set' do
    externals = Externals.new
    assert_equal 'Saver', externals.saver.class.name
  end

end
