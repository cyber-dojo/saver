require_relative 'test_base'
require_relative 'rack_request_stub'
require_relative 'storer_stub'
require_relative '../../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF066'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {},
      'hello from StorerStub.sha'
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
    assert_dispatch_raises('increments',
      { id: malformed_id },
      500,
      'ArgumentError',
      'id:malformed'
    )
    assert_dispatch_raises('tag_visible_files',
      {  id: well_formed_id,
        tag: malformed_tag
      },
      500,
      'ArgumentError',
      'tag:malformed'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch to create' do
    assert_dispatch('create',
      { manifest: create_manifest },
      'hello from StorerStub.create'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5E',
  'dispatch to manifest' do
    assert_dispatch('manifest',
      { id: well_formed_id },
      'hello from StorerStub.manifest'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E60',
  'dispatch to id' do
    assert_dispatch('id',
      { id: well_formed_id },
      'hello from StorerStub.id?'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E61',
  'dispatch to id_completed' do
    assert_dispatch('id_completed',
      { partial_id: well_formed_partial_id},
      'hello from StorerStub.id_completed'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E62',
  'dispatch to id_completions' do
    assert_dispatch('id_completions',
      { outer_id: well_formed_outer_id},
      'hello from StorerStub.id_completions'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E70',
  'dispatch to ran_tests' do
    assert_dispatch('ran_tests',
      {     id: well_formed_id,
         files: well_formed_files,
           now: well_formed_now,
        stdout: well_formed_stdout,
        stderr: well_formed_stderr,
        colour: well_formed_colour
      },
      'hello from StorerStub.ran_tests'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E71',
  'dispatch to increments' do
    assert_dispatch('increments',
      { id: well_formed_id},
      'hello from StorerStub.increments'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E80',
  'dispatch to visible_files' do
    assert_dispatch('visible_files',
      { id: well_formed_id },
      'hello from StorerStub.visible_files'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E81',
  'dispatch to tag_visible_files' do
    assert_dispatch('tag_visible_files',
      {  id: well_formed_id,
        tag: well_formed_tag
      },
      'hello from StorerStub.tag_visible_files'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E82',
  'dispatch to tags_visible_files' do
    assert_dispatch('tags_visible_files',
      {      id: well_formed_id,
        was_tag: well_formed_was_tag,
        now_tag: well_formed_now_tag
      },
      'hello from StorerStub.tags_visible_files'
    )
  end

=begin
  test 'E68',
  'dispatch to tag_fork' do
    assert_dispatch('tag_fork',
      { id:well_formed_id,
        tag:well_formed_tag,
        now:well_formed_now
      },
      'hello from StorerStub.tag_fork'
    )
  end
=end

  private

  def malformed_id
    '==' # ! Base58 String
  end

  def malformed_tag
    'sdsd' # !Integer
  end

  def well_formed_id
    '1234567890'
  end

  def well_formed_partial_id
    '123456'
  end

  def well_formed_outer_id
    '12'
  end

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

  def well_formed_colour
    'red'
  end

  def well_formed_tag
    4
  end

  def well_formed_was_tag
    7
  end

  def well_formed_now_tag
    8
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    qname = (name == 'id') ? 'id?' : name
    assert_rack_call(name, args, { qname => stubbed })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_raises(name, args, status, class_name, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    assert_equal status, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_exception(response[2][0], class_name, message)
    assert_exception(stderr, class_name, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception(s, class_name, message)
    json = JSON.parse(s)
    exception = json['exception']
    refute_nil exception
    assert_equal class_name, exception['class']
    assert_equal message, exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_rack_call(name, args, expected)
    response = rack_call(name, args)
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_equal [ to_json(expected) ], response[2], args
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def rack_call(name, args)
    rack = RackDispatcher.new(StorerStub.new, RackRequestStub)
    env = { path_info:name, body:args.to_json }
    rack.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def to_json(o)
    JSON.pretty_generate(o)
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
