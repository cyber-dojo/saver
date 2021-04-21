# frozen_string_literal: true
require_relative 'test_base'

class SaverRunUntilFalseTest < TestBase

  def self.hex_prefix
    '86A'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_until_false()
  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '512', %w(
  |run_until_false()
  |completes all its commands
  |when nothing returns false
  ) do
    dirname = 'client/batch-run-until-false/x3/t5/12'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'newtyle tay beat'
    command(true, file_create_command(filename, content))
    command(true, file_append_command(filename, '1'))
    command(content+'1', file_read_command(filename))
    assert_run_until_false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '513', %w(
  |run_until_false()
  |stops at exists?() returning false
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-false/x3/t5/13'
    command(true, dir_make_command(dirname))
    command(true, dir_exists_command(dirname))
    command(false, dir_exists_command(dirname+'X'))
    filename = dirname + '/stops-at-exists-false.txt'
    content = 'dalmarnock tay beat'
    not_run(file_create_command(filename, content))
    assert_run_until_false
    assert dir_exists?(dirname)
    refute dir_exists?(dirname+'X'), :does_not_execute_subsequent_commands
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '514', %w(
  |run_until_false()
  |stops at create() returning false
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-false/x3/t5/14'
    command(true, dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    filename = dirname + '/stops-at-exists.txt'
    content = 'stenton tay beat'
    not_run(file_create_command(filename, content))
    assert_run_until_false
    assert dir_exists?(dirname)
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '515', %w(
  |run_until_false()
  |stops at write() already existing file
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-false/x3/t5/15'
    command(true, dir_make_command(dirname))
    filename = dirname + '/stops-at-write-false.txt'
    content = 'murthly tay beat'
    command(true, file_create_command(filename, content))
    command(false, file_create_command(filename, content))
    not_run(file_append_command(filename, 'extra'))
    assert_run_until_false
    assert dir_exists?(dirname)
    assert_equal content, file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '516', %w(
  |run_until_false()
  |stops at append() to non-existant file
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-false/x3/t5/16'
    command(true, dir_make_command(dirname))
    filename = dirname + '/stops-at-append-false.txt'
    content = 'park dee beat'
    command(true, file_create_command(filename, content))
    command(true, file_append_command(filename, '1'))
    command(true, file_append_command(filename, '2'))
    command(false, file_append_command(filename+'X', '3'))
    not_run(file_append_command(filename, '4'))
    assert_run_until_false
    assert dir_exists?(dirname)
    assert_equal content+'12', file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '517', %w(
  |run_until_false()
  |stops at read() non-existent file
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-false/x3/t5/17'
    command(true, dir_make_command(dirname))
    filename = dirname + '/stops-at-read-false.txt'
    content = 'inchmarlo dee beat'
    command(true, file_create_command(filename, content))
    command(false, file_read_command(filename+'X'))
    not_run(file_append_command(filename, 'extra'))
    assert_run_until_false
    assert_equal content, file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # raises when malformed commands

  test '121', %w(
  |when commands is not an Array
  |raise
  ) do
    commands = 23
    message = 'malformed:commands:!Array (Integer):'
    assert_raises_SaverException(message,commands) {
      saver.run_until_false(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '122', %w(
  |when commands entry is not an Array
  |raise
  ) do
    commands = [42]
    message = 'malformed:commands[0]:!Array (Integer):'
    assert_raises_SaverException(message,commands) {
      saver.run_until_false(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '123', %w(
  |when commands entry is unknown
  |raise
  ) do
    commands = [['hgttg']]
    message = 'malformed:commands[0]:Unknown (hgttg):'
    assert_raises_SaverException(message,commands) {
      saver.run_until_false(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '124', %w(
  |when commands entry is incorrect arity
  |raises
  ) do
    commands = [['dir_make','abc/d/e/f'],['file_read',1,2,3,4,5,6]]
    message = 'malformed:commands[1]:file_read!6:'
    assert_raises_SaverException(message,commands) {
      saver.run_until_false(commands)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '125', %w(
  |when commands entry has non String parameter
  |raises
  ) do
    commands = [['dir_exists?','abc/d/e/f'],['dir_make',nil]]
    message = 'malformed:commands[1]:dir_make(dirname!=String):'
    assert_raises_SaverException(message,commands) {
      saver.run_until_false(commands)
    }
  end

  private

  def command(expected, cmd)
    @expected << expected
    @commands << cmd
  end

  def not_run(cmd)
    @commands << cmd
  end

  def assert_run_until_false
    result = saver.run_until_false(@commands)
    assert_equal @expected, result
  end

  # - - - - - - - - - - - - - - - -

  def dir_exists?(dirname)
    saver.run(dir_exists_command(dirname))
  end

  def file_read(filename)
    saver.run(file_read_command(filename))
  end

  # - - - - - - - - - - - - - - - -

  def assert_raises_SaverException(message, commands)
    error = assert_raises(::HttpJsonHash::ServiceError) { yield }
    expected_args = { commands:commands }
    assert_equal expected_args, error.args

    exception = JSON.parse!(error.body)['exception']
    assert_equal message, exception['message'], :message
    assert_equal 'SaverService', exception['class'], :class
    assert_equal JSON.generate(expected_args), exception['body'], :body
  end

end
