require_relative 'test_base'

class RackDispatchingTest < TestBase

  def self.id58_prefix
    'FF0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 500
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '166',
  'dispatch has 500 status when no space left on device' do
    externals.instance_exec {
      # See docker-compose.yml
      # See scripts/containers_up.sh create_space_limited_volume()
      @disk = External::Disk.new('one_k')
    }
    dirname = '166'
    filename = '166/file'
    content = 'x'*1024
    disk.assert(command:dir_make_command(dirname))
    disk.assert(command:file_create_command(filename, content))
    message = "No space left on device @ io_write - /one_k/#{filename}"
    body = { "command": file_append_command(filename, content*16) }.to_json
    assert_post_raises('run', body, 500, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '167',
  'dispatch has 500 status when assert_all raises' do
    message = 'commands[1] != true'
    dirname = '167'
    body = { "commands":[
      dir_make_command(dirname),
      dir_make_command(dirname) # repeat
    ]}.to_json
    assert_post_raises('assert_all', body, 500, message)
    disk.assert(command:dir_exists_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1A',
  'dispatch has 500 status when implementation raises' do
    def prober.sha
      raise ArgumentError, 'wibble'
    end
    assert_get_raises('sha', '{}', 500, 'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1B',
  'dispatch has 500 status when implementation has syntax error' do
    def prober.sha
      raise SyntaxError, 'fubar'
    end
    assert_get_raises('sha', '{}', 500, 'fubar')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 400
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2A',
  'dispatch has 404 when method name is not found' do
    response,_stdout,_stderr = with_captured_stdout_stderr do
      post_json '/xyz', '{}'
    end
    assert_equal 404, response.status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2B',
  'dispatch has 400 status when body is not JSON' do
    assert_post_raises('run',
      'xxx',
      400,
      'body is not JSON')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2C',
  'dispatch has 400 status when body is not JSON Hash' do
    assert_post_raises('run',
      '[]',
      400,
      'body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC6',
  'dispatch has 400 status when commands is missing' do
    assert_post_raises('run_all',
      '{}',
      400,
      'missing:commands:'
    )
  end

  test 'AC7',
  'dispatch has 400 status when commands are malformed' do
    [
      ['{"commands":42}', 'malformed:commands:!Array (Integer):'],
      ['{"commands":[42]}', 'malformed:commands[0]:!Array (Integer):'],
      ['{"commands":[[true]]}', 'malformed:commands[0][0]:!String (TrueClass):'],
      ['{"commands":[["xxx"]]}', 'malformed:commands[0]:Unknown (xxx):'],
      ['{"commands":[["file_read",1,2,3]]}', 'malformed:commands[0]:file_read!3:'],
      ['{"commands":[["file_read",2.9]]}', 'malformed:commands[0]:file_read(filename!=String):']
    ].each do |json, error_message|
      assert_post_raises('run_all', json, 400, error_message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC8',
  'dispatch has 400 status when command is missing' do
    assert_post_raises('assert',
      '{}',
      400,
      'missing:command:'
    )
  end

  test 'AC9',
  'dispatch has 400 status when command is malformed' do
    [
      ['{"command":42}', 'malformed:command:!Array (Integer):'],
      ['{"command":[true]}', 'malformed:command[0]:!String (TrueClass):'],
      ['{"command":["xxx"]}', 'malformed:command:Unknown (xxx):'],
      ['{"command":["file_read",1,2,3]}', 'malformed:command:file_read!3:'],
      ['{"command":["file_read",2.9]}', 'malformed:command:file_read(filename!=String):']
    ].each do |json, error_message|
      assert_post_raises('assert', json, 400, error_message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200 probes
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E39',
  'dispatches to alive' do
    def prober.alive?
      'hello from alive?'
    end
    assert_get('alive' , ''  , prober.alive?)
    assert_get('alive?', ''  , prober.alive?)
    assert_get('alive' , '{}', prober.alive?)
    assert_get('alive?', '{}', prober.alive?)
  end

  test 'E40',
  'dispatches to ready' do
    def prober.ready?
      'hello from ready?'
    end
    assert_get('ready' , ''  , prober.ready?)
    assert_get('ready?', ''  , prober.ready?)
    assert_get('ready' , '{}', prober.ready?)
    assert_get('ready?', '{}', prober.ready?)
  end

  test 'E41',
  'dispatches to sha' do
    def prober.sha
      'hello from sha'
    end
    assert_get('sha', ''  , prober.sha)
    assert_get('sha', '{}', prober.sha)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200 batches
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E48',
  'dispatches to assert_all' do
    disk_stub('assert_all')
    assert_post('assert_all',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed disk.assert_all'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E51',
  'dispatches to assert' do
    disk_stub('assert')
    assert_post('assert',
      { command: well_formed_command }.to_json,
      'hello from stubbed disk.assert'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E52',
  'dispatches to run' do
    disk_stub('run')
    assert_post('run',
      { command: well_formed_command }.to_json,
      'hello from stubbed disk.run'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E47',
  'dispatches to run_all' do
    disk_stub('run_all')
    assert_post('run_all',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed disk.run_all'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E49',
  'dispatches to run_until_true' do
    disk_stub('run_until_true')
    assert_post('run_until_true',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed disk.run_until_true'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E50',
  'dispatches to run_until_false' do
    disk_stub('run_until_false')
    assert_post('run_until_false',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed disk.run_until_false'
    )
  end

  private

  def disk_stub(name)
    disk.define_singleton_method(name) do |*_args|
      "hello from stubbed disk.#{name}"
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

  def assert_get(name, body, expected_body)
    response = get_json(name, body)
    assert_equal 200, response.status
    assert_equal 'application/json', response.headers['Content-Type']
    expected = { queryfied(name) => expected_body }.to_json
    assert_equal expected, response.body, body
  end

  def assert_post(name, body, expected_body)
    response = post_json(name, body)
    assert_equal 200, response.status
    assert_equal 'application/json', response.headers['Content-Type']
    expected = { name => expected_body }.to_json
    assert_equal expected, response.body, body
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def queryfied(name)
    if query?(name)
      name + '?'
    else
      name
    end
  end

  def query?(name)
    %w( alive ready exists group_exists kata_exists ).include?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_get_raises(name, body, expected_status, expected_body)
    assert_raises(name, expected_status, expected_body) do
      get_json '/'+name, body
    end
  end

  def assert_post_raises(name, body, expected_status, expected_body)
    assert_raises(name, expected_status, expected_body) do
      post_json '/'+name, body
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_raises(name, expected_status, expected_body)
    response,stdout,stderr = with_captured_stdout_stderr do
      yield
    end
    diagnostic = "stdout:#{stdout}:\nstderr:#{stderr}:"

    assert_equal '', stdout, diagnostic
    refute_equal '', stderr, diagnostic

    actual_type = response.headers["Content-Type"]
    actual_status = response.status
    actual_body = response.body

    assert_equal 'application/json', actual_type, diagnostic
    assert_equal expected_status, actual_status, diagnostic

    assert_exception_content(actual_body, name, expected_body)
    assert_exception_content(stderr,      name, expected_body)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception_content(s, name, message)
    json = JSON.parse!(s)
    exception = json['exception']
    refute_nil exception
    assert_equal '/'+name, exception['path'], "path:#{__LINE__}"
    assert_equal 'SaverService', exception['class'], "exception['class']:#{__LINE__}"
    assert_equal message, exception['message'], "exception['message']:#{__LINE__}"
    assert_equal 'Array', exception['backtrace'].class.name, "exception['backtrace'].class.name:#{__LINE__}"
    assert_equal 'String', exception['backtrace'][0].class.name, "exception['backtrace'][0].class.name:#{__LINE__}"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stdout_stderr
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new('', 'w')
    $stderr = StringIO.new('', 'w')
    response = yield
    return [ response, $stderr.string, $stdout.string ]
  ensure
    $stderr = old_stderr
    $stdout = old_stdout
  end

end
