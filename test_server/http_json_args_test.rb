# frozen_string_literal: true
require_relative 'test_base'
require_relative '../src/http_json_args'
require_relative '../src/http_json/request_error'

class HttpJsonArgsTest < TestBase

  def self.hex_prefix
    '0A1'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9AD', %w(
    allow empty body in parameterless http requests;
    this is important for curl based requests,
    especially kubernetes liveness/readyness probes
  ) do
    args = HttpJsonArgs.new('')
    assert_equal [saver,'alive?',{}], args.get('/alive', externals)
    assert_equal [saver,'ready?',{}], args.get('/ready', externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F18', 'get: [saver] path and body ok' do
    args = HttpJsonArgs.new('{}')
    assert_equal [saver,'sha',{}], args.get('/sha', externals)
    assert_equal [saver,'alive?',{}], args.get('/alive', externals)
    assert_equal [saver,'ready?',{}], args.get('/ready', externals)

    dirname = 'F18'
    filename = dirname + '/' + 'readme.txt'
    content = 'hello world'

    command = dir_make_command(dirname)
    args = HttpJsonArgs.new({"command":command}.to_json)
    expected = [saver,'run',{ command: command}]
    assert_equal expected, args.get('/run', externals)

    commands = [
        dir_make_command(dirname),
        file_create_command(filename, content)
    ]
    args = HttpJsonArgs.new({"commands":commands}.to_json)
    expected = [saver,'run_all',{ commands: commands }]
    assert_equal expected, args.get('/run_all', externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # c'tor
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A04',
  'ctor raises when its string arg is not JSON' do
    expected = 'body is not JSON'
    info = 'abc is not a valid top-level JSON element'
    error = assert_raises { HttpJsonArgs.new('abc') }
    assert_equal expected, error.message, info
    info = 'nil is null in JSON'
    error = assert_raises { HttpJsonArgs.new('{"x":nil}') }
    assert_equal expected, error.message, info
    info = 'keys have to be strings in JSON'
    error = assert_raises { HttpJsonArgs.new('{42:"answer"}') }
    assert_equal expected, error.message, info
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A05',
  'ctor raises when its string arg is not JSON Hash' do
    expected = 'body is not JSON Hash'
    error = assert_raises { HttpJsonArgs.new('[]') }
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # get

  test 'A06',
  'get raises when path is unknown' do
    args = HttpJsonArgs.new('{}')
    error = assert_raises { args.get('/nope', externals) }
    assert_equal 'unknown path', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # get:command

  test 'C50',
  'command: get() raises when it is missing' do
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    error = assert_raises { args.get('/run', externals) }
    assert_equal 'missing:command:', error.message
  end

  test 'C51',
  'command: get() raises when it is missing' do
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    error = assert_raises { args.get('/assert', externals) }
    assert_equal 'missing:command:', error.message
  end

  test 'C52',
  'command: get() raises when it is not an Array' do
    command = 'Hello'
    error = assert_assert_raises(command)
    assert_equal 'malformed:command:!Array (String):', error.message
  end

  test 'C55',
  'command: get() raises when name is unknown' do
    command = ['spey','ff']
    error = assert_assert_raises(command)
    assert_equal 'malformed:command:Unknown (spey):', error.message
  end

  test 'C58',
  'command: get() raises when dir_make-command does not have one argument' do
    command = ['dir_make']
    error = assert_assert_raises(command)
    assert_equal 'malformed:command:dir_make!0:', error.message
  end

  test 'C63',
  'command: get() raises when any 1st argument is not a string' do
    command = ['file_read',42]
    error = assert_assert_raises(command)
    assert_equal 'malformed:command:file_read(filename!=String):', error.message
  end

  test 'C64',
  'command: get() raises when any 2nd argument is not a string' do
    command = ['file_create','a/b/c',nil]
    error = assert_assert_raises(command)
    assert_equal 'malformed:command:file_create(content!=String):', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # get:commands

  test 'B51',
  'commands: get() raises when it is missing' do
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    error = assert_raises { args.get('/run_all', externals) }
    assert_equal 'missing:commands:', error.message
  end

  test 'B52',
  'commands: get() raises when it is not an Array' do
    commands = 42
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands:!Array (Integer):', error.message
  end

  test 'B53',
  'commands[i]: get() raises when it is not an Array' do
    commands = [['dir_exists?','a/b/c'],true]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[1]:!Array (TrueClass):', error.message
  end

  test 'B54',
  'commands[i]: get() raises when name is not a String' do
    commands = [['dir_exists?','/d/e/f'],[4.2]]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[1][0]:!String (Float):', error.message
  end

  test 'B55',
  'commands[i]: get() raises when name is unknown' do
    commands = [['dir_make','/t/45/readme.md'],['qwerty','ff']]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[1]:Unknown (qwerty):', error.message
  end

  test 'B58',
  'commands[i]: get() raises when dir_make-command does not have one argument' do
    commands = [['dir_make']]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:dir_make!0:', error.message
  end

  test 'B59',
  'commands[i]: get() raises when dir_exists-command does not have one argument' do
    commands = [['dir_exists?','a','b','c']]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:dir_exists?!3:', error.message
  end

  test 'B60',
  'commands[i]: get() raises when file_create-command does not have two arguments' do
    commands = [['file_create','a','b','c','d']]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:file_create!4:', error.message
  end

  test 'B61',
  'commands[i]: get() raises when file_append-command does not have two arguments' do
    commands = [['file_append','a']]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:file_append!1:', error.message
  end

  test 'B62',
  'commands[i]: get() raises when file_read-command does not have one argument' do
    commands = [['file_read']]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:file_read!0:', error.message
  end

  test 'B63',
  'commands[i]: get() raises when any 1st argument is not a string' do
    commands = [['file_read',42]]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:file_read(filename!=String):', error.message
  end

  test 'B64',
  'commands[i]: get() raises when any 2nd argument is not a string' do
    commands = [['file_create','a/b/c',nil]]
    error = assert_run_all_raises(commands)
    assert_equal 'malformed:commands[0]:file_create(content!=String):', error.message
  end

  private

  def assert_assert_raises(command)
    json = { "command":command }.to_json
    args = HttpJsonArgs.new(json)
    assert_raises { args.get('/assert', externals) }
  end

  def assert_run_all_raises(commands)
    json = { "commands":commands }.to_json
    args = HttpJsonArgs.new(json)
    assert_raises { args.get('/run_all', externals) }
  end

end
