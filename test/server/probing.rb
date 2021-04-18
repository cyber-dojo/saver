# frozen_string_literal: true
require_relative 'test_base'

class ProbingTest < TestBase

  def self.hex_prefix
    'AEA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha

  test '190', %w( sha is sha of image's git commit ) do
    sha = prober.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready?

  test '602',
  %w( ready? is always true ) do
    assert prober.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # alive?

  test '603',
  %w( alive? is always true ) do
    assert prober.alive?
  end

end