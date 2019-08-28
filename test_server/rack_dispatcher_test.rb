require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  #====================================================
  # saver
  #====================================================
  # 500

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

  test 'E2A',
  'dispatch raises 400 when method name is unknown' do
    assert_dispatch_raises('xyz',
      {}.to_json,
      400,
      'unknown path')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2B',
  'dispatch returns 400 status when JSON is malformed' do
    assert_dispatch_raises('xyz',
      [].to_json,
      400,
      'body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200

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

  test 'E47',
  'dispatches to batch_read' do
    saver_stub('batch_read')
    assert_saver_dispatch('batch_read',
      { keys: well_formed_keys }.to_json,
      'hello from stubbed saver.batch_read'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E48',
  'dispatches to batch_until_false' do
    saver_stub('batch_until_false')
    assert_saver_dispatch('batch_until_false',
      { commands: well_formed_commands }.to_json,
      'hello from stubbed saver.batch_until_false'
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

  private

  def saver_stub(name)
    saver.define_singleton_method name do |*_args|
      "hello from stubbed saver.#{name}"
    end
  end

  # - - - - - - -

  def well_formed_key
    '/cyber-dojo/katas/12/34/56/event.json' # String
  end

  def well_formed_value
    { "a" => 23, "b" => [1,2,3] }.to_json # String
  end

  def well_formed_keys
    [
      '/cyber-dojo/katas/12/34/45/manifest.json',
      '/cyber-dojo/katas/34/56/78/manifest.json'
    ]
  end

  def well_formed_commands
    [
      [ 'make?',   '/cyber-dojo/katas/12/34/45'],
      [ 'write',   '/cyber-dojo/katas/12/34/45/manifest.json', {"a"=>[1,2,3]}.to_json ],
      [ 'exists?', '/cyber-dojo/katas/12/34/45/manifest.json' ]
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
    ['ready','exists','make'].include?(name)
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

=begin
  def malformed_id
    'df/de' # !Base58.string? && size != 6
  end

  def well_formed_id
    '123456'
  end

  def well_formed_indexes
    (0..63).to_a.shuffle
  end

  # - - - - - - -

  def well_formed_index
    2
  end

  def malformed_index
    '23' # !Integer
  end

  # - - - - - - -

  def well_formed_files
    { 'cyber-dojo.sh' => file('make') }
  end

  def well_formed_now
    [2018,3,28, 21,11,39,6543]
  end

  def well_formed_duration
    0.456
  end

  def well_formed_stdout
    file('tweedle-dee')
  end

  def well_formed_stderr
    file('tweedle-dum')
  end

  def well_formed_status
    23
  end

  def well_formed_colour
    'red'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_group_dispatch(name, args, stubbed)
    if query?(name)
      qname = name + '?'
    else
      qname = name
    end
    assert_rack_call('group_'+name, args, { qname => stubbed })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_kata_dispatch(name, args, stubbed)
    if query?(name)
      qname = name + '?'
    else
      qname = name
    end
    assert_rack_call('kata_'+name, args, { qname => stubbed })
  end
=end
