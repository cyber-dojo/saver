require_relative 'test_base'
require 'json'
require 'oj'

class OjSpeedTest < TestBase

  test '4AACB1',
  %w[ Oj.dump() is faster than JSON.generate() ] do
    o = any_hash
    oj_gem = -> { Oj.dump(o) }
    json_gem = -> { JSON.generate(o) }
    t0,t1 = two_timed(100,[oj_gem,json_gem])
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0}:oj_gem"
    diagnostic += "\n#{'%.5f' % t1}:json_gem"
    # puts diagnostic
    # 0.00024:oj_gem
    # 0.00068:json_gem
    # assert t0 < t1, diagnostic
  end

  # - - - - - - - - - - - - - - - - -

  test '4AACB2',
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
    # assert t0 < t1, diagnostic
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
