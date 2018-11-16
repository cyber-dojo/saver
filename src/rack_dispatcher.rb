require_relative 'client_error'
require_relative 'well_formed_args'
require 'json'

class RackDispatcher

  def initialize(externals, request_class)
    @externals = externals
    @request_class = request_class
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info[1..-1]
    body = request.body.read
    target, name, args = validated_name_args(path, body)
    result = target.public_send(name, *args)
    json_response(200, plain({ name => result }))
  rescue => error
    diagnostic = pretty({
      'exception' => {
        'path' => path,
        'body' => body,
        'class' => 'SaverService',
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    })
    $stderr.puts(diagnostic)
    $stderr.flush
    json_response(code(error), diagnostic)
  end

  private # = = = = = = = = = = = = = = = = = = =

  def validated_name_args(name, body)
    @well_formed_args = WellFormedArgs.new(body)
    image = @externals.image
    grouper = @externals.grouper
    singler = @externals.singler
    args = case name
      when /^sha$/            then [image]

      when /^group_exists$/   then [grouper, id]
      when /^group_create$/   then [grouper, manifest]
      when /^group_manifest$/ then [grouper, id]
      when /^group_join$/     then [grouper, id, indexes]
      when /^group_joined$/   then [grouper, id]
      when /^group_events$/   then [grouper, id]

      when /^kata_exists$/    then [singler, id]
      when /^kata_create$/    then [singler, manifest]
      when /^kata_manifest$/  then [singler, id]
      when /^kata_ran_tests$/ then [singler, id, index, files, now, duration, stdout, stderr, status, colour]
      when /^kata_events$/    then [singler, id]
      when /^kata_event$/     then [singler, id, index]

      else
        raise ClientError, "#{name}:unknown:"
    end
    name += '?' if query?(name)
    target = args.shift
    [target, name, args]
  end

  # - - - - - - - - - - - - - - - -

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  def code(error)
    if error.is_a?(ClientError)
      400
    else
      500
    end
  end

  def plain(body)
    JSON.generate(body)
  end

  def pretty(body)
    JSON.pretty_generate(body)
  end

  # - - - - - - - - - - - - - - - -

  def self.well_formed_args(*names)
    names.each do |name|
      define_method name, &lambda {
        @well_formed_args.public_send(name)
      }
    end
  end

  well_formed_args :manifest,
                   :id,
                   :indexes,
                   :index,
                   :files,
                   :now,
                   :duration,
                   :stdout,
                   :stderr,
                   :status,
                   :colour

  # - - - - - - - - - - - - - - - -

  def query?(name)
    ['group_exists','kata_exists'].include?(name)
  end

end