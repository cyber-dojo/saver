require_relative 'test_base'

class RackDispatchingTest < TestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF0E39', %w(
  | dispatches to alive
  ) do
    assert_get('alive' , ''  , 'alive?', true)
    assert_get('alive?', ''  , 'alive?', true)
    assert_get('alive' , '{}', 'alive?', true)
    assert_get('alive?', '{}', 'alive?', true)
  end

  test 'FF0E40', %w(
  | dispatches to ready
  ) do
    assert_get('ready' , ''  , 'ready?', true)
    assert_get('ready?', ''  , 'ready?', true)
    assert_get('ready' , '{}', 'ready?', true)
    assert_get('ready?', '{}', 'ready?', true)
  end

  test 'FF0E41', %w(
  | dispatches to sha
  ) do
    def prober.sha
      '80206798f1c1e0b403f17ceb1e7510edea8d8e51'
    end
    assert_get('sha', ''  , 'sha', prober.sha)
    assert_get('sha', '{}', 'sha', prober.sha)
  end

  test 'FF0E42', %w(
  | you can pass arguments as path params
  | as that is simpler when calling from JavaScript
  ) do
    assert_get('kata_exists?id=123AbZ', '', 'kata_exists?', false)
    assert_get('kata_exists?id=5rTJv5', '', 'kata_exists?', true)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 400
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF0E2A', %w(
  | dispatch has 404 when method name is not found
  ) do
    response, _stdout, _stderr = with_captured_stdout_stderr do
      post_json '/xyz', ''
    end
    assert_equal 404, response.status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF0E2B', %w(
  | dispatch has 400 status when non-empty body is not JSON
  ) do
    response, _stdout, _stderr = with_captured_stdout_stderr do
      get_json '/sha', 'abc'
    end
    assert_equal 400, response.status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF0E2C', %w(
  | dispatch has 400 status when non-empty body is not JSON Hash
  ) do
    response, _stdout, _stderr = with_captured_stdout_stderr do
      get_json '/sha', '[]'
    end
    assert_equal 400, response.status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 500
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF0F1A', %w(
  | dispatch has 500 status when implementation raises
  ) do
    def prober.sha
      raise ArgumentError, 'wibble'
    end
    assert_get_raises('sha', '', 500, 'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF0F1B', %w(
  | dispatch has 500 status when implementation has syntax error
  ) do
    def prober.sha
      raise SyntaxError, 'fubar'
    end
    assert_get_raises('sha', '', 500, 'fubar')
  end

  private

  def assert_get(name, body, expected_name, expected_body)
    response = get_json(name, body)
    assert_equal 200, response.status, response.body
    assert_equal 'application/json', response.headers['Content-Type']
    expected = { expected_name => expected_body }.to_json
    assert_equal expected, response.body, body
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_get_raises(name, body, expected_status, message)
    assert_dispatch_raises(name, expected_status, message) do
      get_json "/#{name}", body
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_raises(name, expected_status, message)
    response,stdout,stderr = with_captured_stdout_stderr do
      yield
    end
    
    diagnostic = "stdout:#{stdout}:\nstderr:#{stderr}:"
    refute_equal '', stdout, diagnostic
    assert_equal '', stderr, diagnostic

    assert_exception_response(response, expected_status, message)
    assert_exception_stdout(stdout, name, message) 
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception_response(response, expected_status, expected_message)
    expected_body = { 'exception' => expected_message }
    actual_type = response.headers["Content-Type"]
    actual_status = response.status
    actual_body = JSON.parse!(response.body)
    
    assert_equal 'application/json', actual_type, :exception_body_type
    assert_equal expected_status, actual_status, :exception_body_status
    assert_equal expected_body, actual_body, :exception_body_content
  end
  
  def assert_exception_stdout(stdout, name, message)
    json = JSON.parse!(stdout)
    exception = json['exception']
    refute_nil exception
    assert_equal "/#{name}", exception['path'], "path:#{__LINE__}"
    assert_equal message, exception['message'], "exception['message']:#{__LINE__}"
    assert_equal 'Array', exception['backtrace'].class.name, "exception['backtrace'].class.name:#{__LINE__}"
    assert_equal 'String', exception['backtrace'][0].class.name, "exception['backtrace'][0].class.name:#{__LINE__}"
    assert exception.key?('time')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stdout_stderr
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new(+'', 'w')
    $stderr = StringIO.new(+'', 'w')
    response = yield
    [response, $stdout.string, $stderr.string]
  ensure
    $stderr = old_stderr
    $stdout = old_stdout
  end

end
