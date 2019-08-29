require_relative 'test_base'
require 'oj'

class JsonSpeedTest < TestBase

  def self.hex_prefix
    '60E'
  end

  test 'A06', %w( test speed of alternative implementations ) do
    one = '{"s":23,"t":[1,2,3,4,5,6,7],"u":"blah"}'
    all = ([one] * 1242).join("\n")
    _,faster = timed {
      line = '[' + all.lines.join(',') + ']'
      Oj.strict_load(line)
    }
    _,slower = timed {
      all.lines.map { |line|
        Oj.strict_load(line)
      }
    }
    assert faster <= slower, "faster:#{faster}, slower:#{slower}"
  end

  private

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    [result,duration]
  end

end
