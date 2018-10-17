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
    path = request.path_info[1..-1] # lose leading /
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
    args = case name
      when /^sha$/            then [image]

      when /^group_exists$/   then [grouper, id]
      when /^group_create$/   then [grouper, manifest]
      when /^group_manifest$/ then [grouper, id]
      when /^group_join$/     then [grouper, id, indexes]
      when /^group_joined$/   then [grouper, id]

      when /^kata_exists$/    then [singler, id]
      when /^kata_create$/    then [singler, manifest]
      when /^kata_manifest$/  then [singler, id]
      when /^kata_ran_tests$/ then [singler, id, n, files, now, stdout, stderr, status, colour]
      when /^kata_tags$/      then [singler, id]
      when /^kata_tag$/       then [singler, id, n]

      else
        raise ClientError, "#{name}:unknown:"
    end
    name += '?' if query?(name)
    target = args.shift
    [target, name, args]
  end

  def image
    @externals.image
  end

  def grouper
    @externals.grouper
  end

  def singler
    @externals.singler
  end

  # - - - - - - - - - - - - - - - -

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  def plain(body)
    JSON.generate(body)
  end

  def pretty(body)
    JSON.pretty_generate(body)
  end

  def code(error)
    error.is_a?(ClientError) ? 400 : 500
  end

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
                   :n,
                   :files,
                   :now,
                   :stdout,
                   :stderr,
                   :status,
                   :colour

  # - - - - - - - - - - - - - - - -

  def query?(name)
    ['group_exists','kata_exists'].include?(name)
  end

end
