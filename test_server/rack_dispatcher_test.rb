require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  class ThrowingRackDispatcherStub
    def initialize(klass, message)
      @klass = klass
      @message = message
    end
    def sha
      fail @klass, @message
    end
  end

  test 'F1A',
  'dispatch returns 500 status when implementation raises' do
    @stub = ThrowingRackDispatcherStub.new(ArgumentError, 'wibble')
    assert_dispatch_raises('sha', {}.to_json, 500, 'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F1B',
  'dispatch returns 500 status when implementation has syntax error' do
    @stub = ThrowingRackDispatcherStub.new(SyntaxError, 'fubar')
    assert_dispatch_raises('sha', {}.to_json, 500, 'fubar')
  end
=end

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
  'dispatch returns 400 status when JSON is malformed' do
    assert_dispatch_raises('xyz',
      [].to_json,
      400,
      'body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready?
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E40',
  'dispatch to ready' do
    assert_dispatch('ready', {}.to_json,
      "hello from #{stub_name}.saver.ready?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {}.to_json,
      "hello from #{stub_name}.saver.sha"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # group
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5B',
  'dispatch raises 400 when any argument is malformed' do
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
    assert_group_dispatch('exists',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group.exists?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch to group_create' do
    assert_group_dispatch('create',
      { manifest: starter.manifest }.to_json,
      "hello from #{stub_name}.group.create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5E',
  'dispatch to group_manifest' do
    assert_group_dispatch('manifest',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group.manifest"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E63',
  'dispatch to group_join' do
    assert_group_dispatch('join',
      { id: well_formed_id, indexes: well_formed_indexes }.to_json,
      "hello from #{stub_name}.group.join"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E64',
  'dispatch to group_joined' do
    assert_group_dispatch('joined',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group.joined"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E65',
  'dispatch to group_events' do
    assert_group_dispatch('events',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.group.events"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5B',
  'dispatch raises 400 when any argument is malformed' do
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
    assert_kata_dispatch('exists',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.kata.exists?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'dispatch to kata_create' do
    args = { manifest: starter.manifest }.to_json
    assert_kata_dispatch('create', args,
      "hello from #{stub_name}.kata.create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5D',
  'kata_create(manifest) can include group which holds group-id' do
    manifest = starter.manifest
    manifest['group'] = '18Q67A'
    args = { manifest: manifest }.to_json
    assert_kata_dispatch('create', args,
      "hello from #{stub_name}.kata.create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5E',
  'dispatch to kata_manifest' do
    assert_kata_dispatch('manifest',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.kata.manifest"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70',
  'dispatch to kata_ran_tests' do
    assert_kata_dispatch('ran_tests',
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
      "hello from #{stub_name}.kata.ran_tests"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A71',
  'dispatch to kata_events' do
    assert_kata_dispatch('events',
      { id: well_formed_id }.to_json,
      "hello from #{stub_name}.kata.events"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A72',
  'dispatch to kata_event' do
    assert_kata_dispatch('event',
      { id: well_formed_id,
        index: well_formed_index
      }.to_json,
      "hello from #{stub_name}.kata.event"
    )
  end

  private

  def stub_name
    'RackDispatcherStub'
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

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    if query?(name)
      qname = name + '?'
    else
      qname = name
    end
    assert_rack_call(name, args, { qname => stubbed })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def query?(name)
    ['ready','exists'].include?(name)
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

  class SaverStub
    def sha
      "hello from RackDispatcherStub.saver.sha"
    end
    def ready?
      "hello from RackDispatcherStub.saver.ready?"
    end
  end

  # - - - - - - - -

  class GroupStub
    def self.define_stubs(*names)
      names.each do |name|
        define_method name do |*_args|
          "hello from RackDispatcherStub.group.#{name}"
        end
      end
    end
    define_stubs :exists?,
                 :create,
                 :manifest,
                 :join,
                 :joined,
                 :events
  end

  # - - - - - - - -

  class KataStub
    def self.define_stubs(*names)
      names.each do |name|
        define_method name do |*_args|
          "hello from RackDispatcherStub.kata.#{name}"
        end
      end
    end
    define_stubs :exists?,
                 :create,
                 :manifest,
                 :ran_tests,
                 :events,
                 :event
  end

  # - - - - - - - -

  class RackDispatcherExternalsStub
    def group
      @group ||= GroupStub.new
    end
    def kata
      @kata ||= KataStub.new
    end
    def saver
      @saver ||= SaverStub.new
    end
  end

  def rack_call(name, args)
    externals_stub = RackDispatcherExternalsStub.new
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
    old_stderr = $stderr
    $stderr = StringIO.new('', 'w')
    response = yield
    return [ response, $stderr.string ]
  ensure
    $stderr = old_stderr
  end

end
