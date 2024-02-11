require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'lib/json_adapter'
require_relative 'lib/utf8_clean'
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

  def self.get_json(klass_name, method_name)
    get "/#{method_name}", provides:[:json] do
      respond_to do |format|
        format.json do
          json_result(klass_name, method_name)
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.post_json(klass_name, method_name)
    post "/#{method_name}", provides:[:json] do
      respond_to do |format|
        format.json do
          json_result(klass_name, method_name)
        end
      end
    end
  end

  private

  include JsonAdapter
  include Utf8

  def json_result(klass_name, method_name)
    args = to_json_object(request_body)
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
    if error.is_a?(RequestError)
      status(400)
    else
      status(500)
    end
    message = Utf8.clean(error.message)
    $stdout.puts(json_pretty({
      exception: {
        path: Utf8.clean(request.path),
        body: Utf8.clean(request_body),
        backtrace: error.backtrace,
        message: message,
        time: Time.now
      }
    }))
    $stdout.flush
    content_type('application/json')
    body(json_pretty({ exception: message }))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def request_body
    request.body.rewind # For idempotence
    body = request.body.read
    body
  end

end
