# frozen_string_literal: true

require_relative 'http_json/request_error'
require_relative 'http_json_args'
require_relative 'oj_adapter'

class RackDispatcher

  def initialize(externals, request_class)
    @externals = externals
    @request_class = request_class
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info
    body = request.body.read
    target, name, args = HttpJsonArgs.new(body).get(path, @externals)
    result = target.public_send(name, *args)

    if target.is_a?(Group)
      name = 'group_' + name
    end
    if target.is_a?(Kata)
      name = 'kata_' + name
    end

    json_response_pass(200, { name => result })
  rescue HttpJson::RequestError => error
    json_response_fail(400, diagnostic(path, body, error))
  rescue Exception => error
    json_response_fail(500, diagnostic(path, body, error))
  end

  private

  include OjAdapter

  def json_response_pass(status, obj)
    body = json_plain(obj)
    json_response(status, body)
  end

  def json_response_fail(status, obj)
    body = json_pretty(obj)
    $stderr.puts(body)
    $stderr.flush
    json_response(status, body)
  end

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, body, error)
    { 'exception' => {
        'path' => path,
        'body' => body,
        'class' => 'SaverService',
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    }
  end

end
