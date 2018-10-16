require_relative 'rack_dispatcher_externals_stub'
require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  include RackDispatcherExternalsStub

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5A',
  'dispatch raises when method name is unknown' do
    assert_dispatch_raises('unknown',
      {},
      400,
      'SaverService',
      'json:malformed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # image
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {},
      "hello from #{stub_name}.sha"
    )
  end


  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # grouper
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5B',
  'dispatch raises when any argument is malformed' do
    assert_dispatch_raises('group_manifest',
      { id: malformed_id },
      400,
      'SaverService',
      'malformed:id:'
    )
    assert_dispatch_raises('group_join',
      {  id: malformed_id },
      400,
      'SaverService',
      'malformed:id:'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E60',
  'dispatch to group_exists' do
    assert_dispatch('group_exists',
      { id: well_formed_id },
      "hello from #{stub_name}.group_exists?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch to group_create' do
    assert_dispatch('group_create',
      { manifest: starter.manifest },
      "hello from #{stub_name}.group_create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5E',
  'dispatch to group_manifest' do
    assert_dispatch('group_manifest',
      { id: well_formed_id },
      "hello from #{stub_name}.group_manifest"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E63',
  'dispatch to group_join' do
    assert_dispatch('group_join',
      { id: well_formed_id, indexes: well_formed_indexes },
      "hello from #{stub_name}.group_join"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E64',
  'dispatch to group_joined' do
    assert_dispatch('group_joined',
      { id: well_formed_id},
      "hello from #{stub_name}.group_joined"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # singler
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5B',
  'dispatch raises when any argument is malformed' do
    assert_dispatch_raises('kata_tags',
      { id: malformed_id },
      400,
      'SaverService',
      'malformed:id:'
    )
    assert_dispatch_raises('kata_tag',
      {  id: well_formed_id,
          n: malformed_n
      },
      400,
      'SaverService',
      'malformed:n:'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A60',
  'dispatch to kata_exists' do
    assert_dispatch('kata_exists',
      { id: well_formed_id },
      "hello from #{stub_name}.kata_exists?"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'dispatch to kata_create' do
    args = { manifest: starter.manifest }
    assert_dispatch('kata_create', args,
      "hello from #{stub_name}.kata_create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5D',
  'kata_create(manifest) can include group which holds group-id' do
    manifest = starter.manifest
    manifest['group'] = '18Q67A'
    args = { manifest: manifest }
    assert_dispatch('kata_create', args,
      "hello from #{stub_name}.kata_create"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5E',
  'dispatch to kata_manifest' do
    assert_dispatch('kata_manifest',
      { id: well_formed_id },
      "hello from #{stub_name}.kata_manifest"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70',
  'dispatch to kata_ran_tests' do
    assert_dispatch('kata_ran_tests',
      {     id: well_formed_id,
             n: well_formed_n,
         files: well_formed_files,
           now: well_formed_now,
        stdout: well_formed_stdout,
        stderr: well_formed_stderr,
        status: well_formed_status,
        colour: well_formed_colour
      },
      "hello from #{stub_name}.kata_ran_tests"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A71',
  'dispatch to kata_tags' do
    assert_dispatch('kata_tags',
      { id: well_formed_id },
      "hello from #{stub_name}.kata_tags"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A72',
  'dispatch to kata_tag' do
    assert_dispatch('kata_tag',
      { id: well_formed_id,
         n: well_formed_n
      },
      "hello from #{stub_name}.kata_tag"
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

  def well_formed_n
    2
  end

  def malformed_n
    '23' # !Integer
  end

  # - - - - - - -

  def well_formed_files
    { 'cyber-dojo.sh' => 'make' }
  end

  def well_formed_now
    [2018,3,28, 21,11,39]
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

  def assert_dispatch_raises(name, args, status, class_name, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    body = args.to_json
    assert_equal status, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_exception(response[2][0], name, body, class_name, message)
    assert_exception(stderr,         name, body, class_name, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception(s, name, body, class_name, message)
    json = JSON.parse(s)
    exception = json['exception']
    refute_nil exception
    assert_equal name, exception['path']
    assert_equal body, exception['body']
    assert_equal class_name, exception['class']
    assert_equal message, exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
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
    rack = RackDispatcher.new(self, RackRequestStub)
    env = { path_info:name, body:args.to_json }
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
