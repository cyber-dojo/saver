# frozen_string_literal: true
require_relative 'test_base'

class RandomSamplingTest < TestBase

  def self.id58_prefix
    'aA8'
  end

  test '340', %w[ basic sanity check sample(N) returns all of 0 to N-1 inclusive ] do
    size = 16
    counts = {}
    until counts.size == size
      i = random.sample(size)
      assert_equal Integer, i.class
      assert i >= 0, i
      assert i < size, i
      counts[i] ||= 0
      counts[i] += 1
    end
  end

end
