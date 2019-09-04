require_relative 'test_base'
require_relative '../src/http_json_args'
require_relative '../src/http_json/request_error'

class HttpJsonArgsTest < TestBase

  def self.hex_prefix
    '0A1'
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
  # key

  test 'B41',
  'key: get() raises when it is missing' do
    args = HttpJsonArgs.new('{}')
    error = assert_raises { args.get('/create', externals) }
    assert_equal 'missing:key:', error.message
  end

  test 'B42',
  'key: get() raises when it is not a String' do
    args = HttpJsonArgs.new('{"key":42}')
    error = assert_raises { args.get('/create', externals) }
    assert_equal 'malformed:key:!String (Integer):', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # value

  test 'B43',
  'value: get() raises when it is missing' do
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    error = assert_raises { args.get('/write', externals) }
    assert_equal 'missing:value:', error.message
  end

  test 'B44',
  'value: get() raises when it is not a String' do
    args = HttpJsonArgs.new('{"key":"a/b/c","value":42}')
    error = assert_raises { args.get('/write', externals) }
    assert_equal 'malformed:value:!String (Integer):', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  test 'B51',
  'commands: get() raises when it is missing' do
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'missing:commands:', error.message
  end

  test 'B52',
  'commands: get() raises when it is not an Array' do
    args = HttpJsonArgs.new('{"commands":42}')
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands:!Array (Integer):', error.message
  end

  test 'B53',
  'commands[i]: get() raises when it is not an Array' do
    commands = { "commands":[['sha'],['ready'],true] }
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[2]:!Array (TrueClass):', error.message
  end

  test 'B54',
  'commands[i]: get() raises when name is not a String' do
    commands = { "commands": [
      ['sha'],[4.2]
    ]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[1][0]:!String (Float):', error.message
  end

  test 'B55',
  'commands[i]: get() raises when name is unknown' do
    commands = { "commands": [
      ['sha'],['qwerty','ff']
    ]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[1]:Unknown (qwerty):', error.message
  end

  test 'B56',
  'commands[i]: get() raises when sha-command does not have zero arguments' do
    commands = { "commands": [['sha','sss']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:sha!0 (1):', error.message
  end

  test 'B57',
  'commands[i]: get() raises when ready-command does not have zero arguments' do
    commands = { "commands": [['ready','sss','ttt']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:ready!0 (2):', error.message
  end

  test 'B58',
  'commands[i]: get() raises when create-command does not have one argument' do
    commands = { "commands": [['create']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:create!1 (0):', error.message
  end

  test 'B59',
  'commands[i]: get() raises when exists-command does not have one argument' do
    commands = { "commands": [['exists','a','b','c']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:exists!1 (3):', error.message
  end

  test 'B60',
  'commands[i]: get() raises when write-command does not have two arguments' do
    commands = { "commands": [['write','a','b','c','d']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:write!2 (4):', error.message
  end

  test 'B61',
  'commands[i]: get() raises when append-command does not have two arguments' do
    commands = { "commands": [['append','a']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:append!2 (1):', error.message
  end

  test 'B62',
  'commands[i]: get() raises when read-command does not have one argument' do
    commands = { "commands": [['read']]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:read!1 (0):', error.message
  end

  test 'B63',
  'commands[i]: get() raises when any 1st argument is not a string' do
    commands = { "commands": [['read',42]]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:read-1!String (Integer):', error.message
  end

  test 'B64',
  'commands[i]: get() raises when any 2nd argument is not a string' do
    commands = { "commands": [['write','a/b/c',nil]]}
    args = HttpJsonArgs.new(commands.to_json)
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'malformed:commands[0]:write-2!String (NilClass):', error.message
  end

end
