# frozen_string_literal: true
require_relative 'test_base'

class TimeNowTest < TestBase

  def self.hex_prefix
    'a7D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190', %w( time.now sanity check ) do
    now = time.now
    assert_equal Array, now.class
    assert_equal 7, now.size
    now.each { |i| assert_equal Integer, i.class }
  end

end
