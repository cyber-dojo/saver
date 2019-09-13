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
    assert_equal [saver,'alive?',[]], args.get('/alive', externals)
    assert_equal [saver,'ready?',[]], args.get('/ready', externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F18', 'get: [saver] path and body ok' do
    args = HttpJsonArgs.new('{}')
    assert_equal [saver,'sha',[]], args.get('/sha', externals)
    assert_equal [saver,'alive?',[]], args.get('/alive', externals)
    assert_equal [saver,'ready?',[]], args.get('/ready', externals)
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    assert_equal [saver,'create',['a/b/c']], args.get('/create', externals)
    assert_equal [saver,'exists?',['a/b/c']], args.get('/exists', externals)
    assert_equal [saver,'read',['a/b/c']], args.get('/read', externals)
    args = HttpJsonArgs.new('{"key":"a/b/c","value":"qwerty"}')
    assert_equal [saver,'write',['a/b/c','qwerty']], args.get('/write', externals)
    assert_equal [saver,'append',['a/b/c','qwerty']], args.get('/append', externals)
    commands = [['create','a/g/d'],['exists?','a/g/g']]
    json = {"commands":commands}.to_json
    args = HttpJsonArgs.new(json)
    assert_equal [saver,'batch',[commands]], args.get('/batch',externals)
  end

  test 'F19', 'get: [group] path and body ok' do
    args = HttpJsonArgs.new('{"id":"N24Rt6"}')
    assert_equal [group,'exists?',['N24Rt6']], args.get('/group_exists', externals)
    assert_equal [group,'manifest',['N24Rt6']], args.get('/group_manifest', externals)
    assert_equal [group,'joined',['N24Rt6']], args.get('/group_joined', externals)
    assert_equal [group,'events',['N24Rt6']], args.get('/group_events', externals)
    args = HttpJsonArgs.new('{"id":"N24Rt6","indexes":[3,4,5]}')
    assert_equal [group,'join',['N24Rt6',[3,4,5]]], args.get('/group_join', externals)
    args = HttpJsonArgs.new('{"manifest":{}}')
    assert_equal [group,'create',[{}]], args.get('/group_create', externals)
  end

  test 'F20', 'get: [kata] path and body ok' do
    args = HttpJsonArgs.new('{"id":"M3We9H"}')
    assert_equal [kata,'exists?',['M3We9H']], args.get('/kata_exists',externals)
    assert_equal [kata,'manifest',['M3We9H']], args.get('/kata_manifest', externals)
    assert_equal [kata,'events',['M3We9H']], args.get('/kata_events', externals)
    args = HttpJsonArgs.new('{"id":"D3A8q9","index":34}')
    assert_equal [kata,'event',['D3A8q9',34]], args.get('/kata_event', externals)
    args = HttpJsonArgs.new('{"manifest":{}}')
    assert_equal [kata,'create',[{}]], args.get('/kata_create', externals)
    args = HttpJsonArgs.new({
      "id":(id='4rtHd2'),
      "index":(index=21),
      "files":(files={}),
      "now":(now=[2019,6,7, 3,5,8,2344]),
      "duration":(duration=1.52),
      "stdout":(stdout='ssss'),
      "stderr":(stderr='ffff'),
      "status":(status=4),
      "colour":(colour='red')
    }.to_json)
    expected = [kata,'ran_tests',[id,index,files,now,duration,stdout,stderr,status,colour]]
    assert_equal expected, args.get('/kata_ran_tests', externals)
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
  # get:key

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
  # get:value

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
  # get:commands

  test 'B51',
  'commands: get() raises when it is missing' do
    args = HttpJsonArgs.new('{"key":"a/b/c"}')
    error = assert_raises { args.get('/batch', externals) }
    assert_equal 'missing:commands:', error.message
  end

  test 'B52',
  'commands: get() raises when it is not an Array' do
    commands = 42
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands:!Array (Integer):', error.message
  end

  test 'B53',
  'commands[i]: get() raises when it is not an Array' do
    commands = [['exists?','a/b/c'],true]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[1]:!Array (TrueClass):', error.message
  end

  test 'B54',
  'commands[i]: get() raises when name is not a String' do
    commands = [['exists?','/d/e/f'],[4.2]]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[1][0]:!String (Float):', error.message
  end

  test 'B55',
  'commands[i]: get() raises when name is unknown' do
    commands = [['create','/t/45/readme.md'],['qwerty','ff']]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[1]:Unknown (qwerty):', error.message
  end

  test 'B58',
  'commands[i]: get() raises when create-command does not have one argument' do
    commands = [['create']]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:create!1 (0):', error.message
  end

  test 'B59',
  'commands[i]: get() raises when exists-command does not have one argument' do
    commands = [['exists?','a','b','c']]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:exists?!1 (3):', error.message
  end

  test 'B60',
  'commands[i]: get() raises when write-command does not have two arguments' do
    commands = [['write','a','b','c','d']]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:write!2 (4):', error.message
  end

  test 'B61',
  'commands[i]: get() raises when append-command does not have two arguments' do
    commands = [['append','a']]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:append!2 (1):', error.message
  end

  test 'B62',
  'commands[i]: get() raises when read-command does not have one argument' do
    commands = [['read']]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:read!1 (0):', error.message
  end

  test 'B63',
  'commands[i]: get() raises when any 1st argument is not a string' do
    commands = [['read',42]]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:read-1!String (Integer):', error.message
  end

  test 'B64',
  'commands[i]: get() raises when any 2nd argument is not a string' do
    commands = [['write','a/b/c',nil]]
    error = assert_batch_raises(commands)
    assert_equal 'malformed:commands[0]:write-2!String (NilClass):', error.message
  end

  private

  def assert_batch_raises(commands)
    json = { "commands":commands }.to_json
    args = HttpJsonArgs.new(json)
    assert_raises { args.get('/batch', externals) }
  end

end
