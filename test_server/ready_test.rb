require_relative 'test_base'

class ReadyTest < TestBase

  def self.hex_prefix
    '0B2'
  end

  # - - - - - - - - - - - - - - - - -

  test '602',
  %w( ready? ) do
    assert ready?
  end

end
