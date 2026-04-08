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

  # - - - - - - - - - - - - - - - - - - - - - -

  # One Mutex per kata id, serialising all POST requests for the same kata
  # across Puma threads. This ensures multi-step operations such as
  # file_rename (which calls git_ff_merge_worktree twice) are atomic:
  # no competing thread can interleave between the two commits.
  #
  # KATA_MUTEXES_LOCK is needed because the GIL can be released between the
  # "key absent?" check and the default-block assignment in the Hash, allowing
  # two threads to each create a different Mutex for the same id. Without the
  # lock they would synchronise on different objects and the race would not be
  # prevented for that operation.
  #
  # Known limitation: entries are never removed, so the hash grows by one
  # small Mutex object per kata ever seen in this process. Each entry is only
  # a few dozen bytes; a busy server with tens of thousands of katas would
  # accumulate only a few MB in total.
  KATA_MUTEXES_LOCK = Mutex.new
  KATA_MUTEXES = Hash.new { |h, k| h[k] = Mutex.new }

  def self.post_json_with_mutex(klass_name, method_name)
    post "/#{method_name}", provides:[:json] do
      # :nocov:
      respond_to do |format|
        format.json do
          id = to_json_object(request_body)['id']
          mutex = AppBase::KATA_MUTEXES_LOCK.synchronize { AppBase::KATA_MUTEXES[id] }
          mutex.synchronize do
            json_result(klass_name, method_name)
          end
        end
      end
      # :nocov:
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
