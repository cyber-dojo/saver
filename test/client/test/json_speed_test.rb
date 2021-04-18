# frozen_string_literal: true
require_relative 'test_base'
require 'oj'

class JsonSpeedTest < TestBase

  def self.hex_prefix
    '60E'
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'A06', %w( test speed of alternative implementations ) do
    one = '{"s":23,"t":[1,2,3,4,5,6,7],"u":"blah"}'
    all = [one] * 1242
    unlined = all.join(',')
    one_large_load = -> {
      Oj.strict_load('[' + unlined + ']')
    }
    lined = all.join(",\n")
    many_small_loads = -> {
      (lined + ",\n").lines.map { |line|
        Oj.strict_load(line.chop.chop)
      }
    }
    t0,t1 = two_timed(100,[one_large_load,many_small_loads])
    diagnostic = ''
    diagnostic += "\n#{'%.5f' % t0}:one_large_load"
    diagnostic += "\n#{'%.5f' % t1}:many_small_loads"
    #puts diagnostic
    #0.43737:one_large_load
    #0.67263:many_small_loads
    assert t0 < t1, diagnostic
  end

end
