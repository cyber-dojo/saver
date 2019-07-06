require_relative 'hex_mini_test'
require_relative 'starter'
require_relative '../src/externals'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def ready?
    grouper.ready?
  end

  def group_exists?(id)
    grouper.group_exists?(id)
  end

  def group_create(manifest)
    grouper.group_create(manifest)
  end

  def group_manifest(id)
    grouper.group_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    grouper.group_join(id, indexes)
  end

  def group_joined(id)
    grouper.group_joined(id)
  end

  def group_events(id)
    grouper.group_events(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    singler.kata_exists?(id)
  end

  def kata_create(manifest)
    singler.kata_create(manifest)
  end

  def kata_manifest(id)
    singler.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, duration, stdout, stderr, status, colour)
    singler.kata_ran_tests(id, n, files, now, duration, stdout, stderr, status, colour)
  end

  def kata_events(id)
    singler.kata_events(id)
  end

  def kata_event(id, n)
    singler.kata_event(id, n)
  end

  #- - - - - - - - - - - - - - -

  def stub_group_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
    id = group_create(manifest)
    assert_equal stub_id, id
    id
  end

  def stub_kata_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
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

  def grouper
    externals.grouper
  end

  def singler
    externals.singler
  end

  def mapper
    externals.mapper
  end

  def externals
    @externals ||= Externals.new
  end

  def starter
    Starter.new(externals) # only needed in tests
  end

end
