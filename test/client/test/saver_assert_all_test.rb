# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverAssertAllTest < TestBase

  def self.hex_prefix
    'AA2'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '416', %w(
  |assert_all() returns array of results
  |when all commands are true
  ) do
    dirname = 'client/assert-all/e3/t4/16'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    there_yes = dirname + '/there-yes.txt'
    content = 'dunkeld tay beat'
    command(true, file_create_command(there_yes, content))
    command(true, file_append_command(there_yes, content.reverse))
    command(content+content.reverse, file_read_command(there_yes))
    result = saver.assert_all(@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '417', %w(
  |assert_all() raises
  |when any command is not true
  |and subsequent commands are not executed
  ) do
    dirname = 'client/assert-all/e3/t4/17'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    there_yes = dirname + '/there-yes.txt'
    content = 'monaltrie dee beat'
    command(true, file_create_command(there_yes, content))
    there_no = dirname + '/there-not.txt'
    command(false, file_read_command(there_no))
    command(true, file_append_command(there_yes, content.reverse))
    message = 'commands[3] != true'
    assert_raises_SaverException(message,@commands) {
      saver.assert_all(@commands)
    }
    assert_equal content, saver.run(file_read_command(there_yes)), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # raises when malformed commands

  multi_test '121', %w(
  |when commands is not an Array
  |raise
  ) do
    commands = 23
    message = 'malformed:commands:!Array (Integer):'
    assert_raises_SaverException(message,commands) {
      saver.assert_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '122', %w(
  |when commands entry is not an Array
  |raise
  ) do
    commands = [42]
    message = 'malformed:commands[0]:!Array (Integer):'
    assert_raises_SaverException(message,commands) {
      saver.assert_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '123', %w(
  |when commands entry is unknown
  |raise
  ) do
    commands = [['hgttg']]
    message = 'malformed:commands[0]:Unknown (hgttg):'
    assert_raises_SaverException(message,commands) {
      saver.assert_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '124', %w(
  |when commands entry is incorrect arity
  |raises
  ) do
    commands = [['dir_make','abc/d/e/f'],['file_read',1,2,3,4,5,6]]
    message = 'malformed:commands[1]:file_read!6:'
    assert_raises_SaverException(message,commands) {
      saver.assert_all(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '125', %w(
  |when commands entry has non String parameter
  |raises
  ) do
    commands = [['dir_exists?','abc/d/e/f'],['dir_make',nil]]
    message = 'malformed:commands[1]:dir_make(dirname!=String):'
    assert_raises_SaverException(message,commands) {
      saver.assert_all(commands)
    }
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

  def assert_raises_SaverException(message,commands)
    error = assert_raises(SaverService::Error) { yield }
    json = JSON.parse!(error.message)
    assert_equal '/assert_all', json['path'], :path
    expected_body = { 'commands'=>commands }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal message, json['message'], :message
  end

end
