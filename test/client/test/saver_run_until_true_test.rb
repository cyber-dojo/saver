# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverRunUntilTrueTest < TestBase

  def self.hex_prefix
    'A4E'
  end

  def hex_setup
    @expected = []
    @commands = []
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '712', %w(
  |run_until_true()
  |completes all its commands
  }when nothing returns true
  ) do
    dirname = 'client/batch-run-until-true/x3/t7/12'
    filename = dirname + '/read-false.txt'
    command(false, file_read_command(filename+'1'))
    command(false, file_read_command(filename+'2'))
    command(false, file_read_command(filename+'3'))
    command(false, file_read_command(filename+'4'))
    command(false, file_read_command(filename+'5'))
    assert_run_until_true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '713', %w(
  |run_until_true()
  |stops at dir_exists?() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-true/x3/t7/13'
    saver.assert(dir_make_command(dirname))
    command(false, dir_exists_command(dirname+'1'))
    command(false, dir_exists_command(dirname+'2'))
    command(false, dir_exists_command(dirname+'3'))
    command(true,  dir_exists_command(dirname))
    filename = dirname + '/stops-at-exists-true'
    not_run(file_create_command(filename, 'xxx'))
    assert_run_until_true
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '714', %w(
  |run_until_true()
  |stops at dir_make() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-true/x3/t7/14'
    saver.assert(dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    command(false, dir_make_command(dirname))
    command(true,  dir_make_command(dirname+'1'))
    filename = dirname + '1/stops-at-create-true'
    not_run(file_create_command(filename, 'xxx'))
    assert_run_until_true
    assert dir_exists?(dirname+'1'), :does_not_execute_subsequent_commands
    refute file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '715', %w(
  |run_until_true()
  |stops at file_create() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-true/x3/t7/15'
    filename = dirname + '/stop-at-write-true'
    content = 'xxxxxx'
    saver.assert_all([
      dir_make_command(dirname),
      file_create_command(filename, content)
    ])

    command(false, file_create_command(filename, content))
    command(true, file_create_command(filename+'1', content))
    not_run(file_append_command(filename, 'to-the-end'))
    assert_run_until_true
    assert_equal content, file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '716', %w(
  |run_until_true()
  |stops at file_append() returning true
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-true/x3/t7/16'
    filename = dirname + '/stop-at-append-true'
    content = 'X'

    saver.assert_all([
      dir_make_command(dirname),
      file_create_command(filename, content)
    ])

    command(false, file_append_command(filename+'1', content))
    command(true, file_append_command(filename, content))
    not_run(file_append_command(filename, 'to-the-end'))
    assert_run_until_true
    assert_equal 'XX', file_read(filename), :does_not_execute_subsequent_commands
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  multi_test '717', %w(
  |run_until_true()
  |stops at file_read() a file that exists
  |and does not execute subsequent commands
  ) do
    dirname = 'client/batch-run-until-true/x3/t7/17'
    event_3 = dirname + '/3.event.json'
    content = '{"colour":"red"}'

    saver.assert_all([
      dir_make_command(dirname),
      file_create_command(event_3,content)
    ])

    command(false, file_create_command(dirname + '/3.event.json', '{"colour":"amber"}'))
    command(false, file_read_command(dirname + '/0.event.json'))
    command(false, file_read_command(dirname + '/1.event.json'))
    command(false, file_read_command(dirname + '/2.event.json'))
    command(content, file_read_command(dirname + '/3.event.json'))
    not_run(file_create_command(dirname + '/4.event.json', '{"colour":"green"}'))

    assert_run_until_true
    refute file_read(dirname + '/4.event.json'), :does_not_execute_subsequent_commands
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
      saver.run_until_true(commands)
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
      saver.run_until_true(commands)
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
      saver.run_until_true(commands)
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
      saver.run_until_true(commands)
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
      saver.run_until_true(commands)
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

  def assert_run_until_true
    result = saver.run_until_true(@commands)
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

  def assert_raises_SaverException(message,commands)
    error = assert_raises(SaverService::Error) { yield }
    json = JSON.parse!(error.message)
    assert_equal '/run_until_true', json['path'], :path
    expected_body = { 'commands'=>commands }
    assert_equal expected_body, JSON.parse!(json['body']), :body
    assert_equal 'SaverService', json['class'], :class
    assert_equal message, json['message'], :message
  end

end
