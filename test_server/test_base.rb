require_relative 'hex_mini_test'
require_relative 'starter'
require_relative '../src/externals'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
  end

  def saver
    externals.saver
  end

  # - - - - - - - - - - - - - - - -

  def group
    externals.group
  end

  def group_id_generator
    externals.group_id_generator
  end

  def kata
    externals.kata
  end

  def kata_id_generator
    externals.kata_id_generator
  end

  class StubIdGenerator
    def initialize(id)
      @id = id
    end
    attr_reader :id
  end

  def stub_group_create(stub_id)
    externals.instance_eval {
      @group_id_generator = StubIdGenerator.new(stub_id)
    }
    id = group.create(starter.manifest)
    assert_equal stub_id, id
    id
  end

  def stub_kata_create(stub_id)
    externals.instance_eval {
      @kata_id_generator = StubIdGenerator.new(stub_id)
    }
    id = kata.create(starter.manifest)
    assert_equal stub_id, id
    id
  end

  def starter
    @starter ||= Starter.new
  end

  def edited_files
    { 'cyber-dojo.sh' => file('gcc'),
      'hiker.c'       => file('#include "hiker.h"'),
      'hiker.h'       => file('#ifndef HIKER_INCLUDED'),
      'hiker.tests.c' => file('#include <assert.h>')
    }
  end

  def file(content, truncated = false)
    { 'content' => content,
      'truncated' => truncated
    }
  end

  def event0
    {
      'event'  => 'created',
      'time'   => creation_time
    }
  end

  def creation_time
    starter.creation_time
  end

  def make_ran_test_args(id, n, files)
    [ id, n, files, time_now, duration, stdout, stderr, status, red ]
  end

  def time_now
    [2016,12,2, 6,14,57]
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
  
end
