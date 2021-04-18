# frozen_string_literal: true
require_relative 'test_base'

class RandomSampleTest < TestBase

  def self.hex_prefix
    'aA8'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '340', %w( basic sanity check sample(N) returns 0 to N-1 inclusive ) do
    size = 16
    counts = {}
    512.times do
      i = random.sample(size)
      assert_equal Integer, i.class
      assert i >= 0, i
      assert i < size, i
      counts[i] ||= 0
      counts[i] += 1
    end
    assert_equal size, counts.size
  end

end
