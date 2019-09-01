require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/saver_exception'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  # - - - - - - - - - - - - - - - - - -

  def self.v_test(versions, hex_suffix, *lines, &block)
    versions.each do |version|
      v = version.to_s
      v_lines = ["<version=#{v}>"] + lines
      test(hex_suffix + v, *v_lines, &block)
    end
  end

  def v_test?(n)
    test_name.start_with?("<version=#{n.to_s}>")
  end

  def externals
    @externals ||= Externals.new
  end

  # - - - - - - - - - - - - - - - - - -

  def assert_service_error(message, &block)
    error = assert_raises(SaverException) { block.call }
    json = JSON.parse(error.message)
    assert_equal message, json['message']
  end

  # - - - - - - - - - - - - - - - - - -

  def saver
    externals.saver
  end

  def group
    externals.group
  end

  def kata
    externals.kata
  end

  def id_generator
    externals.id_generator
  end

  def starter
    externals.starter
  end

  # - - - - - - - - - - - - - - - - - -

  def make_ran_test_args(id, n, files)
    [ id, n, files, time_now, duration, stdout, stderr, status, red ]
  end

  def time_now
    [2019,12,2, 6,14,57,4587]
  end

  def duration
    1.778
  end

  def stdout
    file('')
  end

  def stderr
    file('Assertion failed: answer() == 42')
  end

  def status
    23
  end

  def red
    'red'
  end

  def edited_files
    { 'cyber-dojo.sh' => file('gcc'),
      'hiker.c'       => file('#include "hiker.h"'),
      'hiker.h'       => file('#ifndef HIKER_INCLUDED'),
      'hiker.tests.c' => file('#include <assert.h>')
    }
  end

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

  def event0
    zero = {
      'event'  => 'created',
      'time'   => creation_time
    }
    if v_test?(2)
      zero['index'] = 0
    end
    zero
  end

  def creation_time
    starter.creation_time
  end

  # - - - - - - - - - - - - - - - - - - - -

  def two_timed(n, algos)
    t0,t1 = 0,0
    n.times do
      # which one to do first?
      if rand(42) % 2 == 0
        t0 += timed { algos[0].call }
        t1 += timed { algos[1].call }
      else
        t1 += timed { algos[1].call }
        t0 += timed { algos[0].call }
      end
    end
    [t0,t1]
  end

  def timed
    started_at = clock_time
    yield
    finished_at = clock_time
    (finished_at - started_at)
  end

  def clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

end
