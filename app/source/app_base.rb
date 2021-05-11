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

  def self.put_json(klass_name, method_name)
    put "/#{method_name}", provides:[:json] do
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

  def json_result(klass_name, method_name)
    target = @externals.public_send(klass_name)
    result = target.public_send(method_name, **named_args)
    content_type(:json)
    method_name = method_name.to_s

    if klass_name == :disk && result.is_a?(String)
      # Careful to leave disk.file_read() as a string
      "{#{quoted(method_name)}:#{result.inspect}}"
    elsif result.is_a?(String) && '[{'.include?(result[0])
      # Optimization:
      # We're not doing a disk operation and we've read aggregate json
      # Embed it directly into the response
      "{#{quoted(method_name)}:#{result}}"
    else
      { method_name => result }.to_json
    end
  end

  def quoted(s)
    '"' + s + '"'
  end

  def named_args
    args = json_hash_parse(request_body)
    Hash[args.map{ |key,value| [key.to_sym, value] }]
  end

  def json_hash_parse(body)
    if body == ''
      json = {}
    else
      json = json_parse(body)
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
    content_type('application/json')
    info = {
      exception: {
        path: ut8_clean(request.path),
        body: ut8_clean(request_body),
        class: 'SaverService',
        backtrace: error.backtrace,
        message: ut8_clean(error.message),
        time: Time.now
      }
    }
    diagnostic = json_pretty(info)
    puts(diagnostic)
    body(diagnostic)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def request_body
    body = request.body.read
    request.body.rewind # For idempotence
    body
  end

  def ut8_clean(s)
    # If encoding is already utf-8 then encoding to utf-8 is a
    # no-op and invalid byte sequences are not detected.
    # Forcing an encoding change detects invalid byte sequences.
    s = s.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    s = s.encode('UTF-8', 'UTF-16')
  end

end
