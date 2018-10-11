require_relative 'test_base'
require_relative '../../src/base58'
require 'open3'

class Base58Test < TestBase

  def self.hex_prefix
    'F3A'
  end

  # - - - - - - - - - - - - - - - - - - -

  test '064', %w(
  alphabet has 58 characters all of which are used ) do
    counts = {}
    base.string(5000).chars.each do |ch|
      counts[ch] = true
    end
    assert_equal 58, counts.keys.size
    assert_equal base.alphabet, counts.keys.sort.join
  end

  # - - - - - - - - - - - - - - - - - - -

  test '065', %w(
  every letter of the alphabet can be used as part of a dir name
  ) do
    base.alphabet.each_char do |letter|
      name = "/tmp/base/#{letter}"
      stdout,stderr,r = Open3.capture3("mkdir -vp #{name}")
      refute_equal '', stdout
      assert_equal '', stderr
      assert_equal 0, r.exitstatus
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  test '066', %w(
  string generation is sufficiently random that there is
  no 6-digit string duplicate in 25,000 repeats ) do
    ids = {}
    repeats = 25000
    repeats.times do
      s = base.string(6)
      ids[s] ||= 0
      ids[s] += 1
    end
    assert repeats, ids.keys.size
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
  end

  private

  def string?(s)
    base.string?(s)
  end

  def base
    Base58
  end

end
