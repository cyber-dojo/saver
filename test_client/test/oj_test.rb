require_relative 'test_base'
require 'json'
require 'oj'

class OjTest < TestBase

  def self.hex_prefix
    '4AA'
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB1',
  %w[ Oj.dump() is faster than JSON.fast_generate() ] do
    o = any_hash
    oj_gem = -> { Oj.dump(o) }
    json_gem = -> { JSON.fast_generate(o) }
    t0,t1 = two_timed(100,[oj_gem,json_gem])
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0}:oj_gem"
    diagnostic += "\n#{'%.5f' % t1}:json_gem"
    # puts diagnostic
    # 0.00024:oj_gem
    # 0.00068:json_gem
    assert t0 < t1, diagnostic
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB2',
  %w[ Oj.strict_load() is faster than JSON.parse() ] do
    s = any_hash.to_json
    assert s.is_a?(String)
    oj_gem = -> { Oj.strict_load(s) }
    json_gem = -> { JSON.parse(s) }
    t0,t1 = two_timed(100,[oj_gem,json_gem])
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0}:oj_gem"
    diagnostic += "\n#{'%.5f' % t1}:json_gem"
    # puts diagnostic
    # 0.00046:oj_gem
    # 0.00171:json_gem
    assert t0 < t1, diagnostic
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB3',
  %w[ Oj.strict_load() is compatible with JSON.parse() ] do
    s = any_hash.to_json
    assert_equal JSON.parse(s), Oj.strict_load(s)
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB4',
  %w[ Oj.dump() is compatible with JSON.generate() ] do
    o = any_hash
    assert_equal JSON.generate(o), Oj.dump(o)
    assert_equal JSON.fast_generate(o), Oj.dump(o)
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB5',
  %w( Oj.dump() requires strict mode for full JSON.generate() compatibility ) do
    symbol = :image_name
    o = { symbol => 'cyberdojofoundation/python_pytest' }
    Oj.default_options = { mode: :object }
    refute_equal JSON.generate(o), Oj.dump(o)
    assert_equal JSON.generate(o), Oj.dump(o, {mode: :strict})
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB6',
  %w( Oj setting strict mode as default to simplify dump calls ) do
    symbol = :image_name
    o = { symbol => 'cyberdojofoundation/python_pytest' }
    refute_equal JSON.generate(o), Oj.dump(o)
    Oj.default_options = { mode: :strict }
    assert_equal JSON.generate(o), Oj.dump(o)
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB7',
  %w[ Oj.generate() requires options to mimic JSON.pretty_generate() ] do
    oj_pretty = Oj.generate(any_hash, {
      :space => ' ',
      :indent => '  ',
      :object_nl => "\n",
      :array_nl => "\n"
    })
    json_pretty = JSON.pretty_generate(any_hash)
    assert_equal oj_pretty, json_pretty
  end

  private

  def any_hash
    { 'image_name' => 'cyberdojofoundation/gpp_assert:latest',
      'visible_filenames' => [
        'hello.cpp',
        'hello.hpp',
        'cyber-dojo.sh',
        'makefile'
      ],
      'tab_size' => 4
    }
  end

end
