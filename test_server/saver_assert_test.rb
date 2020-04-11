# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/saver'

class SaverAssertTest < TestBase

  def self.hex_prefix
    'FA2'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # assert()

  test '538',
  'assert() raises when its command is not true' do
    dirname = 'groups/Fw/FP/3p'
    error = assert_raises(RuntimeError) {
      saver.assert(dir_exists_command(dirname))
    }
    assert_equal 'command != true', error.message
    refute saver.run(dir_exists_command(dirname))
  end

  test '539',
  'assert() returns command result when command is true' do
    dirname = 'groups/sw/EP/7K'
    filename = dirname + '/' + '3.events.json'
    content = '{"colour":"red"}'
    saver.assert(dir_make_command(dirname))
    saver.assert(file_create_command(filename, content))
    read = saver.assert(file_read_command(filename))
    assert_equal content, read
  end

end
