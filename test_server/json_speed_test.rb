require_relative 'test_base'
require 'json'

class JsonSpeedTest < TestBase

  def self.hex_prefix
    '60E'
  end

  test 'A06', %w( test speed of alternative implementations ) do
    one = '{"s":23,"t":[1,2,3,4],"u":"blah"}'
    all = ([one] * 142).join("\n")
    _,slower = timed {
      all.lines.map { |line|
        JSON.parse!(line)
      }
    }
    _,faster = timed {
      JSON.parse!('[' + all.lines.join(',') + ']')
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
