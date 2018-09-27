require_relative 'test_base'
require_relative '../../src/base56'

class Base56Test < TestBase

  def self.hex_prefix
    'F3A59'
  end

  # - - - - - - - - - - - - - - - - - - -

  test '064', %w(
  alphabet has 56 characters none of which are missed ) do
    counts = {}
    Base56.string(5000).chars.each do |ch|
      counts[ch] = true
    end
    assert_equal 56, counts.keys.size
  end

  # - - - - - - - - - - - - - - - - - - -

  test '066', %w(
  no 6-digit string duplicate in 25,000 repeats ) do
    ids = {}
    repeats = 25000
    repeats.times do
      s = Base56.string(6)
      ids[s] ||= 0
      ids[s] += 1
    end
    assert_equal 0, repeats - ids.keys.size
  end

  # - - - - - - - - - - - - - - - - - - -

  test '068', %w(
  string?(s) true ) do
    assert string?('012AaEefFgG89Zz')
    assert string?('345BbCcDdEeFfGg')
    assert string?('678HhJjKkMmNnPp')
    assert string?('999PpQqRrSsTtUu')
    assert string?('263VvWwXxYyZz11')
  end

  # - - - - - - - - - - - - - - - - - - -

  test '069', %w(
  string?(s) false ) do
    refute string?(nil)
    refute string?([])
    refute string?(25)
    refute string?('I') # (India)
    refute string?('i') # (india)
    refute string?('O') # (Oscar)
    refute string?('o') # (oscar)
    refute string?('L') # (Lima)
    refute string?('l') # (lima)
  end

  private

  def string?(s)
    Base56.string?(s)
  end

end
