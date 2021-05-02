# frozen_string_literal: true
require_relative 'test_base'

class CustomStartPointsTest < TestBase

  def self.hex_prefix
    '9F2'
  end

  # - - - - - - - - - - - - - - - - -

  test '2C6', 'ready?' do
    assert custom_start_points.ready?
  end

end
