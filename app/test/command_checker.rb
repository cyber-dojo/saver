# frozen_string_literal: true
require_relative 'test_base'
require_source 'command_checker'

class CommandCheckerTest < TestBase

  def self.id58_prefix
    '0a1'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # command

  test 'C51',
  'command: raises when it is missing' do
    error = assert_not_well_formed_command(nil)
    assert_equal 'missing:command:', error.message
  end

  test 'C52',
  'command: raises when it is not an Array' do
    command = 'Hello'
    error = assert_not_well_formed_command(command)
    assert_equal 'malformed:command:!Array (String):', error.message
  end

  test 'C55',
  'command: raises when name is unknown' do
    command = [ 'spey', 'ff' ]
    error = assert_not_well_formed_command(command)
    assert_equal 'malformed:command:Unknown (spey):', error.message
  end

  test 'C58',
  'command: raises when dir_make-command does not have one argument' do
    command = [ 'dir_make' ]
    error = assert_not_well_formed_command(command)
    assert_equal 'malformed:command:dir_make!0:', error.message
  end

  test 'C63',
  'command: raises when any 1st argument is not a string' do
    command = [ 'file_read', 42 ]
    error = assert_not_well_formed_command(command)
    assert_equal 'malformed:command:file_read(filename!=String):', error.message
  end

  test 'C64',
  'command: raises when any 2nd argument is not a string' do
    command = [ 'file_create', 'a/b/c', nil ]
    error = assert_not_well_formed_command(command)
    assert_equal 'malformed:command:file_create(content!=String):', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  test 'B51',
  'commands: raises when it is missing' do
    error = assert_not_well_formed_commands(nil)
    assert_equal 'missing:commands:', error.message
  end

  test 'B52',
  'commands: raises when it is not an Array' do
    commands = 42
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands:!Array (Integer):', error.message
  end

  test 'B53',
  'commands[i]: raises when it is not an Array' do
    commands = [ [ 'dir_exists?', 'a/b/c' ], true ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[1]:!Array (TrueClass):', error.message
  end

  test 'B54',
  'commands[i]: raises when name is not a String' do
    commands = [ ['dir_exists?', '/d/e/f' ], [ 4.2 ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[1][0]:!String (Float):', error.message
  end

  test 'B55',
  'commands[i]: raises when name is unknown' do
    commands = [ [ 'dir_make', '/t/45/readme.md' ], [ 'qwerty', 'ff' ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[1]:Unknown (qwerty):', error.message
  end

  test 'B58',
  'commands[i]: raises when dir_make-command does not have one argument' do
    commands = [ [ 'dir_make' ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:dir_make!0:', error.message
  end

  test 'B59',
  'commands[i]: raises when dir_exists-command does not have one argument' do
    commands = [ [ 'dir_exists?', 'a', 'b', 'c' ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:dir_exists?!3:', error.message
  end

  test 'B60',
  'commands[i]: raises when file_create-command does not have two arguments' do
    commands = [ ['file_create', 'a', 'b', 'c', 'd' ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:file_create!4:', error.message
  end

  test 'B61',
  'commands[i]: raises when file_append-command does not have two arguments' do
    commands = [ [ 'file_append', 'a' ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:file_append!1:', error.message
  end

  test 'B62',
  'commands[i]: raises when file_read-command does not have one argument' do
    commands = [ [ 'file_read' ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:file_read!0:', error.message
  end

  test 'B63',
  'commands[i]: raises when any 1st argument is not a string' do
    commands = [ [ 'file_read', 42 ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:file_read(filename!=String):', error.message
  end

  test 'B64',
  'commands[i]: raises when any 2nd argument is not a string' do
    commands = [ [ 'file_create', 'a/b/c', nil ] ]
    error = assert_not_well_formed_commands(commands)
    assert_equal 'malformed:commands[0]:file_create(content!=String):', error.message
  end

  private

  include CommandChecker

  def assert_not_well_formed_command(command)
    assert_raises { assert_well_formed_command(command) }
  end

  def assert_not_well_formed_commands(commands)
    assert_raises { assert_well_formed_commands(commands) }
  end

end
