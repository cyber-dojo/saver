# frozen_string_literal: true
require_relative '../require_source'
require_source 'app'

module TestHelpersRack

  include Rack::Test::Methods

  def app
    @app ||= App.new(externals)
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

  def assert_json_get_200(method, args)
    stdout,stderr = capture_stdout_stderr {
      get_json '/'+method, args.to_json
    }
    assert_status 200, stdout, stderr
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    if block_given?
      yield json_response_body[method]
    end
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

  def assert_json_post_500(path, body)
    stdout,stderr = capture_stdout_stderr {
      post_json '/'+path, body
    }
    assert_status 500, stdout, stderr
    assert_equal '', stderr, :stderr
    assert_equal stdout, last_response.body+"\n", :stdout
    if block_given?
      yield json_response_body
    end
  end

  def assert_status(expected, stdout, stderr)
    actual = last_response.status
    # :nocov:
    if expected != actual
      print("stdout:\n#{stdout}")
      print("stderr:\n#{stderr}")
      assert_equal expected, actual
    end
    # :nocov:
  end

  def json_response_body
    assert_equal 'application/json', last_response.headers['Content-Type']
    JSON.parse(last_response.body)
  end

end
