require_relative 'grouper_stub'
require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../../src/rack_dispatcher'

class GrouperRackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  def grouper
    GrouperStub.new
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class ImageStub
    def sha
      "hello from #{self.class.name}.sha"
    end
  end

  def image
    ImageStub.new
  end

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {},
      "hello from #{self.class.name}::ImageStub.sha"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5A',
  'dispatch raises when method name is unknown' do
    assert_dispatch_raises('unknown',
      {},
      400,
      'ClientError',
      'json:malformed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5B',
  'dispatch raises when any argument is malformed' do
    assert_dispatch_raises('group_manifest',
      { id: malformed_id },
      500,
      'ArgumentError',
      'id:malformed'
    )
    assert_dispatch_raises('group_join',
      {  id: malformed_id },
      500,
      'ArgumentError',
      'id:malformed'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E60',
  'dispatch to group_exists' do
    assert_dispatch('group_exists',
      { id: well_formed_id },
      'hello from GrouperStub.group_exists?'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch to group_create' do
    assert_dispatch('group_create',
      { manifest: starter.manifest },
      'hello from GrouperStub.group_create'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5E',
  'dispatch to group_manifest' do
    assert_dispatch('group_manifest',
      { id: well_formed_id },
      'hello from GrouperStub.group_manifest'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E63',
  'dispatch to group_join' do
    assert_dispatch('group_join',
      { id: well_formed_id, indexes: well_formed_indexes },
      'hello from GrouperStub.group_join'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E64',
  'dispatch to group_joined' do
    assert_dispatch('group_joined',
      { id: well_formed_id},
      'hello from GrouperStub.group_joined'
    )
  end

  private

  def malformed_id
    'df/de' # !IdGenerator.string? && size != 6
  end

  def well_formed_id
    '123456'
  end

  def well_formed_indexes
    (0..63).to_a.shuffle
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    qname = (name == 'group_exists') ? 'group_exists?' : name
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
