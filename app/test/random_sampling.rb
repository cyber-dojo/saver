# frozen_string_literal: true
require_relative 'test_base'
require_source 'model/id_generator'

class RandomSamplingTest < TestBase

  def self.id58_prefix
    'aA8'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '340', %w[ sample(N) returns all of 0 to N-1 inclusive ] do
    size = ALPHABET_SIZE
    counts = {}
    500.times do
      i = random.sample(size)
      assert_equal Integer, i.class
      assert i >= 0, i
      assert i < size, i
      counts[i] = true
    end
    assert_equal size, counts.size
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '341', %w(
  no id duplicates in 2000
  ) do
    repeats = 2000
    ids = {}
    repeats.times do
      id = 6.times.map { random.sample(ALPHABET_SIZE) }
      ids[id] = true
    end
    assert_equal repeats, ids.size
  end

  ALPHABET_SIZE = IdGenerator::ALPHABET.size

end
