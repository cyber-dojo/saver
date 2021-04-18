# frozen_string_literal: true
require_relative 'test_base'

class DiskAssertTest < TestBase

  def self.hex_prefix
    'FA2'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # assert()

  test '538',
  'assert() raises when its command is not true' do
    dirname = 'groups/Fw/FP/3p'
    error = assert_raises(RuntimeError) {
      saver.assert(command:dir_exists_command(dirname))
    }
    assert_equal 'command != true', error.message
    refute saver.run(command:dir_exists_command(dirname))
  end

  test '539',
  'assert() returns command result when command is true' do
    dirname = 'groups/sw/EP/7K'
    filename = dirname + '/' + '3.events.json'
    content = '{"colour":"red"}'
    saver.assert(command:dir_make_command(dirname))
    saver.assert(command:file_create_command(filename, content))
    read = saver.assert(command:file_read_command(filename))
    assert_equal content, read
  end

end
