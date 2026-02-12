require_relative 'test_base'
require_source 'model/id_generator'

class RandomTest < TestBase

  test 'aA8340', %w(
  | sample(N) returns all of 0 to N-1 inclusive
  ) do
    size = ALPHABET_SIZE
    counts = {}
    1000.times do
      i = random.sample(size)
      assert_equal Integer, i.class
      assert i >= 0, i
      assert i < size, i
      counts[i] = true
    end
    assert_equal size, counts.size
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'aA8341', %w(
  | no sample(N) duplicates in 2000 repeats
  ) do
    repeats = 2000
    ids = {}
    repeats.times do
      id = 6.times.map { random.sample(ALPHABET_SIZE) }
      ids[id] = true
    end
    assert_equal repeats, ids.size
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'aA8342', %w(
  | alphanumeric(N) returns N character string sampled from [0-9A-Za-z]
  ) do
    counts = {}
    1000.times do
      random.alphanumeric(10).chars.each { |ch| counts[ch] = true }
    end
    assert_equal 26 + 26 + 10, counts.size
    expected = [*('0'..'9'), *('A'..'Z'), *('a'..'z')].join
    assert_equal expected, counts.keys.sort.join
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'aA8343', %w(
  | no alphanumeric(6) duplicates in 2000 repeats
  ) do
    repeats = 2000
    ids = {}
    repeats.times do
      id = random.alphanumeric(6)
      ids[id] = true
    end
    assert_equal repeats, ids.size
  end

  ALPHABET_SIZE = IdGenerator::ALPHABET.size
end
