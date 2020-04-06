require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 500
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '166',
  'dispatch returns 500 status when no space left on device' do
    externals.instance_exec {
      # See docker-compose.yml
      # See sh/docker_containers_up.sh create_space_limited_volume()
      @saver = Saver.new('one_k')
    }
    assert saver.create('166')
    assert saver.write('166/file','x'*1024)
    message = 'No space left on device @ io_write - /one_k/166/file'
    body = { "key":'166/file', "value":'x'*1024*16 }.to_json
    assert_dispatch_raises('append', body, 500, message)
    assert saver.exists?('166')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '167',
  'dispatch returns 500 status when batch_assert raises' do
    message = 'commands[1] != true'
    body = { "commands":[['create','167'],['create','167']] }.to_json
    assert_dispatch_raises('batch_assert', body, 500, message)
    assert saver.exists?('167')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1A',
  'dispatch returns 500 status when implementation raises' do
    def saver.sha
      raise ArgumentError, 'wibble'
    end
    assert_dispatch_raises('sha', {}.to_json, 500, 'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1B',
  'dispatch returns 500 status when implementation has syntax error' do
    def saver.sha
      raise SyntaxError, 'fubar'
    end
    assert_dispatch_raises('sha', {}.to_json, 500, 'fubar')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 400
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2A',
  'dispatch raises 400 when method name is unknown' do
    assert_dispatch_raises('xyz',
      {}.to_json,
      400,
      'unknown path')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2B',
  'dispatch returns 400 status when body is not JSON' do
    assert_dispatch_raises('xyz',
      'xxx',
      400,
      'body is not JSON')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2C',
  'dispatch returns 400 status when body is not JSON Hash' do
    assert_dispatch_raises('xyz',
      [].to_json,
      400,
      'body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC2',
  'dispatch returns 400 status when key is missing' do
    assert_dispatch_raises('read',
      '{}',
      400,
      'missing:key:'
    )
  end

  test 'AC3',
  'dispatch returns 400 status when key is malformed' do
    assert_dispatch_raises('read',
      '{"key":42}',
      400,
      'malformed:key:!String (Integer):'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC4',
  'dispatch returns 400 status when value is missing' do
    assert_dispatch_raises('write',
      '{"key":"/a/b/c"}',
      400,
      'missing:value:'
    )
  end

  test 'AC5',
  'dispatch returns 400 status when value is malformed' do
    assert_dispatch_raises('write',
      '{"key":"a/b/c","value":42}',
      400,
      'malformed:value:!String (Integer):'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC6',
  'dispatch returns 400 status when commands is missing' do
    assert_dispatch_raises('batch',
      '{}',
      400,
      'missing:commands:'
    )
  end

  test 'AC7',
  'dispatch returns 400 status when commands are malformed' do
    [
      ['{"commands":42}', 'malformed:commands:!Array (Integer):'],
      ['{"commands":[42]}', 'malformed:commands[0]:!Array (Integer):'],
      ['{"commands":[[true]]}', 'malformed:commands[0][0]:!String (TrueClass):'],
      ['{"commands":[["xxx"]]}', 'malformed:commands[0]:Unknown (xxx):'],
      ['{"commands":[["read",1,2,3]]}', 'malformed:commands[0]:read!1 (3):'],
      ['{"commands":[["read",2.9]]}', 'malformed:commands[0]:read-1!String (Float):']
    ].each do |json, error_message|
      assert_dispatch_raises('batch', json, 400, error_message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC8',
  'dispatch returns 400 status when command is missing' do
    assert_dispatch_raises('assert',
      '{}',
      400,
      'missing:command:'
    )
  end

  test 'AC9',
  'dispatch returns 400 status when command is malformed' do
    [
      ['{"command":42}', 'malformed:command:!Array (Integer):'],
      ['{"command":[true]}', 'malformed:command[0]:!String (TrueClass):'],
      ['{"command":["xxx"]}', 'malformed:command:Unknown (xxx):'],
      ['{"command":["read",1,2,3]}', 'malformed:command:read!1 (3):'],
      ['{"command":["read",2.9]}', 'malformed:command:read-1!String (Float):']
    ].each do |json, error_message|
      assert_dispatch_raises('assert', json, 400, error_message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E39',
  'dispatches to alive' do
    saver_stub('alive?')
    assert_saver_dispatch('alive', {}.to_json,
      'hello from stubbed saver.alive?'
    )
  end

  test 'E40',
  'dispatches to ready' do
    saver_stub('ready?')
    assert_saver_dispatch('ready', {}.to_json,
      'hello from stubbed saver.ready?'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatches to sha' do
    saver_stub('sha')
    assert_saver_dispatch('sha', {}.to_json,
      'hello from stubbed saver.sha'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E42',
  'dispatches to exists?' do
    saver_stub('exists?')
    assert_saver_dispatch('exists',
      { key: well_formed_key }.to_json,
      'hello from stubbed saver.exists?'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E44',
  'dispatches to write' do
    saver_stub('write')
    assert_saver_dispatch('write',
      { key: well_formed_key, value: well_formed_value }.to_json,
      'hello from stubbed saver.write'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E45',
  'dispatches to append' do
    saver_stub('append')
    assert_saver_dispatch('append',
      { key: well_formed_key, value: well_formed_value }.to_json,
      'hello from stubbed saver.append'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E46',
  'dispatches to read' do
    saver_stub('read')
    assert_saver_dispatch('read',
      { key: well_formed_key }.to_json,
      'hello from stubbed saver.read'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E48',
  'dispatches to batch_assert' do
    saver_stub('batch_assert')
    assert_saver_dispatch('batch_assert',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.batch_assert'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E51',
  'dispatches to assert' do
    saver_stub('assert')
    assert_saver_dispatch('assert',
      { command: well_formed_command }.to_json,
      'hello from stubbed saver.assert'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E47',
  'dispatches to batch' do
    saver_stub('batch')
    assert_saver_dispatch('batch',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.batch'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E49',
  'dispatches to batch_until_true' do
    saver_stub('batch_until_true')
    assert_saver_dispatch('batch_until_true',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.batch_until_true'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E50',
  'dispatches to batch_until_false' do
    saver_stub('batch_until_false')
    assert_saver_dispatch('batch_until_false',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.batch_until_false'
    )
  end

  private

  def saver_stub(name)
    saver.define_singleton_method name do |*_args|
      "hello from stubbed saver.#{name}"
    end
  end

  # - - - - - - -

  def well_formed_key
    '/katas/12/34/56/event.json' # String
  end

  def well_formed_value
    { "index" => 23, "time" => [2019,2,3,6,57,8,3242] }.to_json # String
  end

  def well_formed_command
    [ 'create',  '/cyber-dojo/katas/12/34/45' ]
  end

  def well_formed_commands
    [
      [ 'create',  '/cyber-dojo/katas/12/34/45' ],
      [ 'exists?', '/cyber-dojo/katas/12/34/45' ],
      [ 'write',   '/cyber-dojo/katas/12/34/45/manifest.json', {"a"=>[1,2,3]}.to_json ],
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_saver_dispatch(name, args, stubbed)
    if query?(name)
      qname = name + '?'
    else
      qname = name
    end
    assert_rack_call(name, args, { qname => stubbed })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def query?(name)
    %w( alive ready exists group_exists kata_exists ).include?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_raises(name, args, status, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    assert_equal status, response[0], "message:#{message},stderr:#{stderr}"
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_exception(response[2][0], name, args, message)
    assert_exception(stderr,         name, args, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception(s, name, body, message)
    json = JSON.parse!(s)
    exception = json['exception']
    refute_nil exception
    assert_equal '/'+name, exception['path'], "path:#{__LINE__}"
    assert_equal body, exception['body'], "body:#{__LINE__}"
    assert_equal 'SaverService', exception['class'], "exception['class']:#{__LINE__}"
    assert_equal message, exception['message'], "exception['message']:#{__LINE__}"
    assert_equal 'Array', exception['backtrace'].class.name, "exception['backtrace'].class.name:#{__LINE__}"
    assert_equal 'String', exception['backtrace'][0].class.name, "exception['backtrace'][0].class.name:#{__LINE__}"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_rack_call(name, args, expected)
    response = rack_call(name, args)
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_equal [to_json(expected)], response[2], args
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def rack_call(name, args)
    rack = RackDispatcher.new(externals, RackRequestStub)
    env = { path_info:name, body:args }
    rack.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def to_json(body)
    JSON.generate(body)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stderr
    old_stderr = $stderr
    $stderr = StringIO.new('', 'w')
    response = yield
    return [ response, $stderr.string ]
  ensure
    $stderr = old_stderr
  end

end
