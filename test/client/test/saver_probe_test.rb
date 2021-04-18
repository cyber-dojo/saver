# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverProbeTest < TestBase

  def self.hex_prefix
    '6E3'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha

  multi_test '190', %w( sha is sha of image's git commit ) do
    sha = saver.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready?

  multi_test '602',
  %w( ready? is always true ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # alive?

  multi_test '603',
  %w( alive? is always true ) do
    assert saver.alive?
  end

end
