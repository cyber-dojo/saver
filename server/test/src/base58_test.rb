require_relative 'test_base'
require_relative '../../src/base58'
require_relative '../../src/external_disk_writer'
require 'open3'

class Base58Test < TestBase

  def self.hex_prefix
    'F3A'
  end

  def alphabet
    Base58.alphabet
  end

  # - - - - - - - - - - - - - - - - - - -

  test '064', %w(
  alphabet has 58 characters all of which get used ) do
    counts = {}
    Base58.string(5000).chars.each do |ch|
      counts[ch] = true
    end
    assert_equal 58, counts.keys.size
    assert_equal alphabet.chars.sort.join, counts.keys.sort.join
  end

  # - - - - - - - - - - - - - - - - - - -

  test '065', %w(
  every letter of the alphabet can be used as part of a dir name
  which contains files that can be written to and read from
  ) do
    disk = ExternalDiskWriter.new
    diagnostic = 'forward slash is the dir separator'
    refute alphabet.include?('/'), diagnostic
    diagnostic = 'dot is a dir navigator'
    refute alphabet.include?('.'), diagnostic
    diagnostic = 'single quote to protect all other letters'
    refute alphabet.include?("'"), diagnostic
    alphabet.each_char do |letter|
      name = "/tmp/base/#{letter}"
      dir = disk[name]
      refute dir.exists?
      dir.make
      assert dir.exists?
      filename = 'readme.txt'
      content = 'hello world'
      dir.write(filename, content)
      assert_equal content, dir.read(filename)
      dir.append(filename, content.reverse)
      assert_equal content+content.reverse, dir.read(filename)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  test '066', %w(
  string generation is sufficiently random that there is
  no 6-digit string duplicate in 25,000 repeats ) do
    ids = {}
    repeats = 25000
    repeats.times do
      s = Base58.string(6)
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
    Base58.string?(s)
  end

end
