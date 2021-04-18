require_relative 'rack_request_stub'
require_relative 'test_base'
require_source 'rack_dispatcher'

class RackDispatchingTest < TestBase

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
    dirname = '166'
    filename = '166/file'
    content = 'x'*1024
    saver.assert(command:dir_make_command(dirname))
    saver.assert(command:file_create_command(filename,content))
    message = "No space left on device @ io_write - /one_k/#{filename}"
    body = { "command": file_append_command(filename, content*16) }.to_json
    assert_dispatch_raises('run', body, 500, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '167',
  'dispatch returns 500 status when assert_all raises' do
    message = 'commands[1] != true'
    dirname = '167'
    body = { "commands":[
      dir_make_command(dirname),
      dir_make_command(dirname) # repeat
    ]}.to_json
    assert_dispatch_raises('assert_all', body, 500, message)
    saver.assert(command:dir_exists_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1A',
  'dispatch returns 500 status when implementation raises' do
    def prober.sha
      raise ArgumentError, 'wibble'
    end
    assert_dispatch_raises('sha', {}.to_json, 500, 'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1B',
  'dispatch returns 500 status when implementation has syntax error' do
    def prober.sha
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

  test 'AC6',
  'dispatch returns 400 status when commands is missing' do
    assert_dispatch_raises('run_all',
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
      ['{"commands":[["file_read",1,2,3]]}', 'malformed:commands[0]:file_read!3:'],
      ['{"commands":[["file_read",2.9]]}', 'malformed:commands[0]:file_read(filename!=String):']
    ].each do |json, error_message|
      assert_dispatch_raises('run_all', json, 400, error_message)
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
      ['{"command":["file_read",1,2,3]}', 'malformed:command:file_read!3:'],
      ['{"command":["file_read",2.9]}', 'malformed:command:file_read(filename!=String):']
    ].each do |json, error_message|
      assert_dispatch_raises('assert', json, 400, error_message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200 probes
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E39',
  'dispatches to alive' do
    prober_stub('alive?')
    assert_saver_dispatch('alive', {}.to_json,
      'hello from stubbed prober.alive?'
    )
  end

  test 'E40',
  'dispatches to ready' do
    prober_stub('ready?')
    assert_saver_dispatch('ready', {}.to_json,
      'hello from stubbed prober.ready?'
    )
  end

  test 'E41',
  'dispatches to sha' do
    prober_stub('sha')
    assert_saver_dispatch('sha', {}.to_json,
      'hello from stubbed prober.sha'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200 batches
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E48',
  'dispatches to assert_all' do
    saver_stub('assert_all')
    assert_saver_dispatch('assert_all',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.assert_all'
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

  test 'E52',
  'dispatches to run' do
    saver_stub('run')
    assert_saver_dispatch('run',
      { command: well_formed_command }.to_json,
      'hello from stubbed saver.run'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E47',
  'dispatches to run_all' do
    saver_stub('run_all')
    assert_saver_dispatch('run_all',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.run_all'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E49',
  'dispatches to run_until_true' do
    saver_stub('run_until_true')
    assert_saver_dispatch('run_until_true',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.run_until_true'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E50',
  'dispatches to run_until_false' do
    saver_stub('run_until_false')
    assert_saver_dispatch('run_until_false',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.run_until_false'
    )
  end

  private

  def saver_stub(name)
    saver.define_singleton_method name do |*_args|
      "hello from stubbed saver.#{name}"
    end
  end

  def prober_stub(name)
    prober.define_singleton_method name do |*_args|
      "hello from stubbed prober.#{name}"
    end
  end

  # - - - - - - -

  def well_formed_command
    [ 'dir_make',  '/cyber-dojo/katas/12/34/45' ]
  end

  def well_formed_commands
    [
      [ 'dir_make',    '/cyber-dojo/katas/12/34/45' ],
      [ 'dir_exists?', '/cyber-dojo/katas/12/34/45' ],
      [ 'file_create', '/cyber-dojo/katas/12/34/45/manifest.json', {"a"=>[1,2,3]}.to_json ],
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
