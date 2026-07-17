require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'lib/json_adapter'
require_relative 'lib/utf8_clean'
require_relative 'no_longer_implemented_error'
require_relative 'request_error'
require 'json'

class AppBase < Sinatra::Base

  silently { register Sinatra::Contrib } # respond_to
  set :json_encoder, Sinatra::JSON       # avoids MultiJson.encode deprecation warning
  set :port, ENV['PORT']
  set :host_authorization, { permitted_hosts: [] } # https://github.com/sinatra/sinatra/issues/2065#issuecomment-2484285707

  def initialize(externals)
    @externals = externals
    super(nil)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.get_json(klass_name, method_name)
    get "/#{method_name}", provides:[:json] do
      respond_to do |format|
        format.json do
          args = to_json_object(request_body)
          json_result(klass_name, method_name, args)
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.post_json(klass_name, method_name)
    post "/#{method_name}", provides:[:json] do
      respond_to do |format|
        format.json do
          args = to_json_object(request_body)
          # The saver assigns each event's position (head + 1), so no write uses
          # the client index; strip it here so the write methods take no index. The
          # fork methods keep it (index is their fork point, not an event position).
          unless [:group_fork, :kata_fork].include?(method_name)
            args.delete('index')
          end
          json_result(klass_name, method_name, args)
        end
      end
    end
  end

  private

  include JsonAdapter
  include Utf8

  def json_result(klass_name, method_name, args)
    named_args = Hash[args.map{ |key,value| [key.to_sym, value] }]
    target = @externals.public_send(klass_name)
    result = target.public_send(method_name, **named_args)
    content_type(:json)
    { method_name.to_s => result }.to_json
  end

  def to_json_object(body)
    if body != ''
      json = json_parse(body)
    elsif params.empty?
      json = {}
    else
      json = params.map{ |key,value| [key,value] }.to_h
    end
    unless json.instance_of?(Hash)
      fail RequestError, 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $!
    if error.is_a?(NoLongerImplementedError)
      status(505)
    elsif error.is_a?(RequestError)
      status(400)
    else
      status(500)
    end
    message = Utf8.clean(error.message)
    stdout_stream.puts(json_pretty({
      exception: {
        path: Utf8.clean(request.path),
        body: Utf8.clean(request_body),
        backtrace: error.backtrace,
        message: message,
        time: Time.now
      }
    }))
    stdout_stream.flush
    content_type('application/json')
    body(json_pretty({ exception: message }))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def stdout_stream
    Thread.current[:stdout_stream] || $stdout
  end

  def request_body
    request.body.rewind
    request.body.read
  end

end
