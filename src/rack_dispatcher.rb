# frozen_string_literal: true

require_relative 'externals'
require_relative 'http_json/request_error'
require_relative 'http_json_args'
require 'oj'

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

  def json_response_pass(status, json)
    body = Oj.dump(json, { :mode => :strict })
    json_response(status, body)
  end

  def json_response_fail(status, json)
    body = Oj.generate(json, OJ_PRETTY_OPTIONS)
    $stderr.puts(body)
    $stderr.flush
    json_response(status, body)
  end

  OJ_PRETTY_OPTIONS = {
    :space => ' ',
    :indent => '  ',
    :object_nl => "\n",
    :array_nl => "\n"
  }

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
