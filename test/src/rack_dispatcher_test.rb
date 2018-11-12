require_relative 'rack_dispatcher_externals_stub'
require_relative 'rack_dispatcher_stub'
require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class ThrowingRackDispatcherStub
    def sha
      fail ArgumentError, 'wibble'
    end
  end

  test 'F1A',
  'dispatch returns 500 status when implementation raises' do
    @stub = ThrowingRackDispatcherStub.new
    assert_dispatch_raises('sha',
      {}.to_json,
      500,
      'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5A',
  'dispatch raises when method name is unknown' do
    assert_dispatch_raises('xyz',
      {}.to_json,
      400,
      'xyz:unknown:')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # image
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {}.to_json,
      "hello from #{stub_name}.sha"
    )
  end


  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # grouper
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5B',
  'dispatch raises when any argument is malformed' do
    assert_dispatch_raises('group_manifest',
      { id: malformed_id }.to_json,
      400,
      'malformed:id:!Base58:'
    )
    assert_dispatch_raises('group_join',
      {  id: malformed_id }.to_json,
      400,
      'malformed:id:!Base58:'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E60',
  'dispatch to group_exists' do
    assert_dispatch('group_exists',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group_exists?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch to group_create' do
    assert_dispatch('group_create',
      { manifest: starter.manifest }.to_json,
      "hello from #{stub_name}.group_create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5E',
  'dispatch to group_manifest' do
    assert_dispatch('group_manifest',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group_manifest"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E63',
  'dispatch to group_join' do
    assert_dispatch('group_join',
      { id: well_formed_id, indexes: well_formed_indexes }.to_json,
      "hello from #{stub_name}.group_join"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E64',
  'dispatch to group_joined' do
    assert_dispatch('group_joined',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group_joined"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # singler
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5B',
  'dispatch raises when any argument is malformed' do
    assert_dispatch_raises('kata_events',
      { id: malformed_id }.to_json,
      400,
      'malformed:id:!Base58:'
    )
    assert_dispatch_raises('kata_event',
      {  id: well_formed_id,
         index: malformed_index
      }.to_json,
      400,
      'malformed:index:!Integer:'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A60',
  'dispatch to kata_exists' do
    assert_dispatch('kata_exists',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.kata_exists?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'dispatch to kata_create' do
    args = { manifest: starter.manifest }.to_json
    assert_dispatch('kata_create', args,
      "hello from #{stub_name}.kata_create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5D',
  'kata_create(manifest) can include group which holds group-id' do
    manifest = starter.manifest
    manifest['group'] = '18Q67A'
    args = { manifest: manifest }.to_json
    assert_dispatch('kata_create', args,
      "hello from #{stub_name}.kata_create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5E',
  'dispatch to kata_manifest' do
    assert_dispatch('kata_manifest',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.kata_manifest"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70',
  'dispatch to kata_ran_tests' do
    assert_dispatch('kata_ran_tests',
      {     id: well_formed_id,
         index: well_formed_index,
         files: well_formed_files,
           now: well_formed_now,
      duration: well_formed_duration,
        stdout: well_formed_stdout,
        stderr: well_formed_stderr,
        status: well_formed_status,
        colour: well_formed_colour
      }.to_json,
      "hello from #{stub_name}.kata_ran_tests"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A71',
  'dispatch to kata_events' do
    assert_dispatch('kata_events',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.kata_events"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A72',
  'dispatch to kata_event' do
    assert_dispatch('kata_event',
      { id: well_formed_id,
        index: well_formed_index
      }.to_json,
      "hello from #{stub_name}.kata_event"
    )
  end

  private

  def stub_name
    stub.class.name
  end

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
    { 'cyber-dojo.sh' => 'make' }
  end

  def well_formed_now
    [2018,3,28, 21,11,39,6543]
  end

  def well_formed_duration
    0.456
  end

  def well_formed_stdout
    'tweedle-dee'
  end

  def well_formed_stderr
    'tweedle-dum'
  end

  def well_formed_status
    23
  end

  def well_formed_colour
    'red'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    if name.end_with?('_exists')
      qname = name + '?'
    else
      qname = name
    end
    assert_rack_call(name, args, { qname => stubbed })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_raises(name, args, status, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    assert_equal status, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_exception(response[2][0], name, args, message)
    assert_exception(stderr,         name, args, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception(s, name, body, message)
    json = JSON.parse(s)
    exception = json['exception']
    refute_nil exception
    assert_equal name, exception['path']
    assert_equal body, exception['body']
    assert_equal 'SaverService', exception['class']
    assert_equal message, exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
    assert_equal 'String', exception['backtrace'][0].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_rack_call(name, args, expected)
    response = rack_call(name, args)
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_equal [to_json(expected)], response[2], args
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def stub
    @stub ||= RackDispatcherStub.new
  end

  def rack_call(name, args)
    externals_stub = RackDispatcherExternalsStub.new(stub)
    rack = RackDispatcher.new(externals_stub, RackRequestStub)
    env = { path_info:name, body:args }
    rack.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def to_json(body)
    JSON.generate(body)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stderr
    begin
      old_stderr = $stderr
      $stderr = StringIO.new('', 'w')
      response = yield
      return [ response, $stderr.string ]
    ensure
      $stderr = old_stderr
    end
  end

end
