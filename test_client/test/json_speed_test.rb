require_relative 'test_base'
require 'oj'

class JsonSpeedTest < TestBase

  def self.hex_prefix
    '60E'
  end

  test 'A06', %w( test speed of alternative implementations ) do
    one = '{"s":23,"t":[1,2,3,4,5,6,7],"u":"blah"}'
    all = ([one] * 1242).join("\n")
    many_joins_one_json_load = -> {
      line = '[' + all.lines.join(',') + ']'
      Oj.strict_load(line)
    }
    one_map_many_json_loads = -> {
      all.lines.map { |line|
        Oj.strict_load(line)
      }
    }
    t0,t1 = two_timed(100,[many_joins_one_json_load,one_map_many_json_loads])
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0}:many_joins_one_json_load"
    diagnostic += "\n#{'%.5f' % t1}:one_map_many_json_loads"
    #puts diagnostic
    # 0.43576:many_joins_one_json_load
    # 0.54228:one_map_many_json_loads
    assert t0 < t1, diagnostic
  end

end
