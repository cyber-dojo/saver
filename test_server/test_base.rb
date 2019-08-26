require_relative 'hex_mini_test'
require_relative 'starter'
require_relative '../src/externals'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def ready?
    group.ready?
  end

  def group_exists?(id)
    group.group_exists?(id)
  end

  def group_create(manifest)
    group.group_create(manifest)
  end

  def group_manifest(id)
    group.group_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    group.group_join(id, indexes)
  end

  def group_joined(id)
    group.group_joined(id)
  end

  def group_events(id)
    group.group_events(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    katas.kata_exists?(id)
  end

  def kata_create(manifest)
    katas.kata_create(manifest)
  end

  def kata_manifest(id)
    katas.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, duration, stdout, stderr, status, colour)
    katas.kata_ran_tests(id, n, files, now, duration, stdout, stderr, status, colour)
  end

  def kata_events(id)
    katas.kata_events(id)
  end

  def kata_event(id, n)
    katas.kata_event(id, n)
  end

  #- - - - - - - - - - - - - - -

  class StubIdGenerator
    def initialize(id)
      @id = id
    end
    attr_reader :id
  end

  def stub_group_create(stub_id)
    manifest = starter.manifest
    externals.instance_eval {
      @group_id_generator = StubIdGenerator.new(stub_id)
    }
    id = group_create(manifest)
    assert_equal stub_id, id
    id
  end

  def stub_kata_create(stub_id)
    manifest = starter.manifest
    externals.instance_eval {
      @kata_id_generator = StubIdGenerator.new(stub_id)
    }
    id = kata_create(manifest)
    assert_equal stub_id, id
    id
  end

  #- - - - - - - - - - - - - - -

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

  private

  def group
    externals.group
  end

  def katas
    externals.katas
  end

  def externals
    @externals ||= Externals.new
  end

  def starter
    Starter.new(externals)
  end

end
