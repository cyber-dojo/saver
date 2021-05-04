# frozen_string_literal: true
require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'lib/json_adapter'
require_relative 'request_error'
require 'json'

class AppBase < Sinatra::Base

  silently { register Sinatra::Contrib }
  set :port, ENV['PORT']

  def initialize(externals)
    @externals = externals
    super(nil)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.get_json(name, klass_name)
    get "/#{name}", provides:[:json] do
      respond_to do |format|
        format.json {
          target = @externals.public_send(klass_name)
          result = target.public_send(name, **named_args)
          result = quote_if_string(result)
          content_type(:json)
          "{\"#{name}\":#{result}}"
        }
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.post_json(name, klass_name)
    post "/#{name}", provides:[:json] do
      respond_to do |format|
        format.json {
          target = @externals.public_send(klass_name)
          result = target.public_send(name, **named_args)
          result = quote_if_string(result)
          content_type(:json)
          "{\"#{name}\":#{result}}"
        }
      end
    end
  end

  private

  include JsonAdapter

  def named_args
    body = request_body
    if body === '' || body === '{}'
      args = {}
    else
      args = json_hash_parse(body)
    end
    Hash[args.map{ |key,value| [key.to_sym, value] }]
  end

  def json_hash_parse(body)
    json = json_parse(body)
    unless json.instance_of?(Hash)
      fail RequestError, 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail RequestError, 'body is not JSON'
  end

  def request_body
    body = request.body.read
    request.body.rewind # Make available to error handler below
    body
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def quote_if_string(result)
    if result.is_a?(String)
      result.inspect
    else
      result
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $!
    if error.is_a?(RequestError)
      status(400)
    else
      status(500)
    end
    content_type('application/json')
    info = {
      exception: {
        path: request.path,
        body: request.body.read,
        class: 'SaverService',
        backtrace: error.backtrace,
        message: error.message,
        time: Time.now
      }
    }
    diagnostic = json_pretty(info)
    puts(diagnostic)
    body(diagnostic)
  end

end
