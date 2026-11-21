require 'rack/test'
require_relative '../require_source'
require_source 'app'

module TestHelpersRack

  include Rack::Test::Methods

  def app
    App.new(externals)
  end

  def get_json(path, args)
    get(path, {}, json_request(args))
    last_response
  end

  def post_json(path, data)
    post(path, data, JSON_REQUEST_HEADERS)
    last_response
  end

  def json_request(args)
    {
      input: args,
      CONTENT_TYPE: 'application/json', # sent
      HTTP_ACCEPT: 'application/json'   # want
    }
  end

  JSON_REQUEST_HEADERS = {
    'CONTENT_TYPE' => 'application/json', # sent
    'HTTP_ACCEPT' => 'application/json'   # want
  }

  # - - - - - - - - - - - - - - - - - - -

  def assert_json_get_200(method, args, &block)
    stdout,stderr = capture_stdout_stderr {
      get_json '/'+method, args.to_json
    }
    assert_status 200, stdout, stderr
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(json_response_body[method])
  end

  def assert_json_post_200(path, body, &block)
    stdout,stderr = capture_stdout_stderr {
      post_json '/'+path, body
    }
    assert_status 200, stdout, stderr
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(json_response_body)
  end

  def assert_status(expected, stdout, stderr)
    message = "stdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_equal expected, last_response.status, message
  end

  def json_response_body
    assert_equal 'application/json', last_response.headers['Content-Type']
    JSON.parse(last_response.body)
  end

end
