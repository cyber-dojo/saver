require_relative 'test_base'
require 'oj'

class JsonSpeedTest < TestBase

  def self.hex_prefix
    '60E'
  end

  test 'A06', %w( test speed of alternative implementations ) do
    one = '{"s":23,"t":[1,2,3,4,5,6,7],"u":"blah"}'
    all = ([one] * 1242).join("\n")
    slower = many_joins_one_json_load(all)
    faster = one_map_many_json_loads(all)
    assert faster <= slower, "faster:#{faster}, slower:#{slower}"
  end

  private

  def many_joins_one_json_load(all)
    timed {
      line = '[' + all.lines.join(',') + ']'
      Oj.strict_load(line)
    }
  end

  def one_map_many_json_loads(all)
    timed {
      all.lines.map { |line|
        Oj.strict_load(line)
      }
    }
  end

  def timed
    yield # run once to prime caches
    started = Time.now
    yield
    finished = Time.now
    '%.4f' % (finished - started)
  end

end
