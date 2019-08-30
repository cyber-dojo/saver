require_relative 'test_base'
require 'json'
require 'oj'

class OjTest < TestBase

  def self.hex_prefix
    '4AA'
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB1',
  %w( oj is faster than standard json fast generation ) do
    o = any_hash
    slower,_ = timed {
      1000.times { JSON.fast_generate(o) }
    }
    faster,_ = timed {
      1000.times { Oj.dump(o) }
    }
    diagnostic = "generating JSON:#{slower}: Oj:#{faster}:"
    # puts diagnostic
    # generating JSON:0.0068: Oj:0.0013:
    assert faster < slower, diagnostic
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB2',
  %w( oj is faster than the standard json gem at parsing ) do
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
  %w( Oj parsing is compatible with standard gem parsing ) do
    s = any_hash.to_json
    assert_equal JSON.parse(s), Oj.strict_load(s)
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB4',
  %w( Oj generation is compatible with standard gem generation ) do
    o = any_hash
    assert_equal JSON.generate(o), Oj.dump(o)
    assert_equal JSON.fast_generate(o), Oj.dump(o)
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB5',
  %w( Oj generation requires strict mode for symbols ) do
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
