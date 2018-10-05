require_relative 'test_base'
require_relative 'rack_request_stub'
require_relative 'grouper_stub'
require_relative '../../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF066'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {},
      'hello from GrouperStub.sha'
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
    assert_dispatch_raises('manifest',
      { id: malformed_id },
      500,
      'ArgumentError',
      'id:malformed'
    )
    assert_dispatch_raises('join',
      {  id: malformed_id },
      500,
      'ArgumentError',
      'id:malformed'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch to create' do
    assert_dispatch('create',
      { manifest: starter.manifest,
        files: starter.files
      },
      'hello from GrouperStub.create'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5E',
  'dispatch to manifest' do
    assert_dispatch('manifest',
      { id: well_formed_id },
      'hello from GrouperStub.manifest'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E60',
  'dispatch to id' do
    assert_dispatch('id',
      { id: well_formed_id },
      'hello from GrouperStub.id?'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E61',
  'dispatch to id_completed' do
    assert_dispatch('id_completed',
      { partial_id: well_formed_partial_id},
      'hello from GrouperStub.id_completed'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E63',
  'dispatch to join' do
    assert_dispatch('join',
      { id: well_formed_id, indexes: well_formed_indexes },
      'hello from GrouperStub.join'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E64',
  'dispatch to joined' do
    assert_dispatch('joined',
      { id: well_formed_id},
      'hello from GrouperStub.joined'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test 'E68',
  'dispatch to tag_fork' do
    assert_dispatch('tag_fork',
      { id:well_formed_id,
        tag:well_formed_tag,
        now:well_formed_now
      },
      'hello from GrouperStub.tag_fork'
    )
  end
=end

  private

  def malformed_id
    '==' # ! Base58 String
  end

  def well_formed_id
    '1234567890'
  end

  def well_formed_partial_id
    '123456'
  end

  def well_formed_indexes
    (0..63).to_a.shuffle
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    qname = (name == 'id') ? 'id?' : name
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
    rack = RackDispatcher.new(GrouperStub.new, RackRequestStub)
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
