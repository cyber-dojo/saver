require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/externals_new'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def self.old_new_test(hex_suffix, *lines, &block)
    old_lines = ['[old]'] + lines
    test(hex_suffix+'0', *old_lines, &block)
    new_lines = ['[new]'] + lines
    test(hex_suffix+'1', *new_lines, &block)
  end

  def externals
    if test_name.start_with?('[new]')
      @externals_new ||= ExternalsNew.new
    else
      @externals ||= Externals.new
    end
  end

  def assert_service_error(message, &block)
    if test_name.start_with?('[new]')
      assert_service_error_new(message, &block)
    else
      assert_service_error_old(message, &block)
    end
  end

  def assert_service_error_new(message, &block)
    error = assert_raises(ArgumentError) { block.call }
    assert_equal message, error.message
  end

  def assert_service_error_old(message, &block)
    error = assert_raises(ServiceError) { block.call }
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

  def group_id_generator
    externals.group_id_generator
  end

  def kata
    externals.kata
  end

  def kata_id_generator
    externals.kata_id_generator
  end

  def starter
    externals.starter
  end

  # - - - - - - - - - - - - - - - - - -

  def creation_time
    starter.creation_time
  end

  def make_ran_test_args(id, n, files)
    [ id, n, files, time_now, duration, stdout, stderr, status, red ]
  end

  def time_now
    [2016,12,2, 6,14,57,4587]
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

end
