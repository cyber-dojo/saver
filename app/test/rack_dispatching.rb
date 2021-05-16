require_relative 'test_base'

class RackDispatchingTest < TestBase

  def self.id58_prefix
    'FF0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 500
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
    response,_stdout,_stderr = with_captured_stdout_stderr do
      get_json '/sha', 'abc'
    end
    assert_equal 400, response.status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2C',
  'dispatch has 400 status when body is not JSON Hash' do
    response,_stdout,_stderr = with_captured_stdout_stderr do
      get_json '/sha', '[]'
    end
    assert_equal 400, response.status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E39',
  'dispatches to alive' do
    assert_get('alive' , ''  , true)
    assert_get('alive?', ''  , true)
    assert_get('alive' , '{}', true)
    assert_get('alive?', '{}', true)
  end

  test 'E40',
  'dispatches to ready' do
    assert_get('ready' , ''  , true)
    assert_get('ready?', ''  , true)
    assert_get('ready' , '{}', true)
    assert_get('ready?', '{}', true)
  end

  test 'E41',
  'dispatches to sha' do
    def prober.sha
      '80206798f1c1e0b403f17ceb1e7510edea8d8e51'
    end
    assert_get('sha', ''  , prober.sha)
    assert_get('sha', '{}', prober.sha)
  end

  private

  def assert_get(name, body, expected_body)
    response = get_json(name, body)
    assert_equal 200, response.status
    assert_equal 'application/json', response.headers['Content-Type']
    expected = { queryfied(name) => expected_body }.to_json
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
    assert_dispatch_raises(name, expected_status, expected_body) do
      get_json '/'+name, body
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_raises(name, expected_status, expected_body)
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
