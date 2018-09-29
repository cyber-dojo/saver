require_relative 'client_error'
require_relative 'well_formed_args'
require 'json'

class RackDispatcher

  def initialize(grouper, request_class)
    @grouper = grouper
    @request_class = request_class
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info[1..-1] # lose leading /
    body = request.body.read
    name, args = validated_name_args(path, body)
    result = @grouper.public_send(name, *args)
    json_response(200, { name => result })
  rescue => error
    info = {
      'exception' => {
        'class' => error.class.name,
        'message' => error.message,
        'args' => body,
        'backtrace' => error.backtrace
      }
    }
    $stderr.puts pretty(info)
    $stderr.flush
    json_response(status(error), info)
  end

  private # = = = = = = = = = = = = = = = = = = =

  def validated_name_args(name, body)
    @well_formed_args = WellFormedArgs.new(body)
    args = case name
      when /^sha$/            then []
      when /^create$/         then [manifest,files]
      when /^manifest$/       then [id]
      when /^id$/             then [id]
      when /^id_completed$/   then [partial_id]
      when /^id_completions$/ then [outer_id]
      when /^join$/           then [id,indexes]
      when /^joined$/         then [id]
      else
        raise ClientError, 'json:malformed'
    end
    name += '?' if query?(name)
    [name, args]
  end

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ pretty(body) ]
    ]
  end

  def pretty(o)
    JSON.pretty_generate(o)
  end

  def status(error)
    error.is_a?(ClientError) ? 400 : 500
  end

  def self.well_formed_args(*names)
    names.each do |name|
      define_method name, &lambda {
        @well_formed_args.send(name)
      }
    end
  end

  well_formed_args :manifest, :files, :indexes
  well_formed_args :id, :partial_id, :outer_id

  # - - - - - - - - - - - - - - - -

  def query?(name)
    name == 'id'
  end

end
