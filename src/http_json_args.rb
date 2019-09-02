# frozen_string_literal: true

require_relative 'http_json/request_error'
require_relative 'oj_adapter'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(body)
    @args = json_parse(body)
    unless @args.is_a?(Hash)
      fail HttpJson::RequestError, 'body is not JSON Hash'
    end
  rescue Oj::ParseError
    fail HttpJson::RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path, externals)
    saver = externals.saver
    group = externals.group
    kata = externals.kata
    args = case path
    when '/sha'     then [saver,'sha']
    when '/ready'   then [saver,'ready?']
    when '/create'  then [saver,'create', key]
    when '/exists'  then [saver,'exists?', key]
    when '/write'   then [saver,'write', key, value]
    when '/append'  then [saver,'append', key, value]
    when '/read'    then [saver,'read', key]
    when '/batch'   then [saver,'batch', commands]

    when '/group_exists'   then [group,'exists?', id]
    when '/group_create'   then [group,'create', manifest]
    when '/group_manifest' then [group,'manifest', id]
    when '/group_join'     then [group,'join', id, indexes]
    when '/group_joined'   then [group,'joined', id]
    when '/group_events'   then [group,'events', id]

    when '/kata_exists'    then [kata,'exists?', id]
    when '/kata_create'    then [kata,'create', manifest]
    when '/kata_manifest'  then [kata,'manifest', id]
    when '/kata_ran_tests' then [kata,'ran_tests', id, index, files, now, duration, stdout, stderr, status, colour]
    when '/kata_events'    then [kata,'events', id]
    when '/kata_event'     then [kata,'event', id, index]

    else
      fail HttpJson::RequestError, 'unknown path'
    end
    target = args.shift
    name = args.shift
    [target, name, args]
  end

  private

  include OjAdapter

  attr_reader :args

  def key
    well_formed_string('key')
  end

  def value
    well_formed_string('value')
  end

  def commands
    well_formed_commands
  end

  # - - - - - - - - - - - - - - -

  def well_formed_string(arg_name)
    unless args.has_key?(arg_name)
      fail missing(arg_name)
    end
    arg = args[arg_name]
    unless arg.is_a?(String)
      fail malformed(arg_name, "!String (#{arg.class.name})")
    end
    arg
  end

  def well_formed_commands
    arg_name = 'commands'
    unless args.has_key?(arg_name)
      fail missing(arg_name)
    end
    arg = args[arg_name]
    # TODO: check commands are well-formed
    arg
  end

  # - - - - - - - - - - - - - - - -

  def missing(arg_name)
    HttpJson::RequestError.new("missing:#{arg_name}:")
  end

  def malformed(arg_name, msg)
    HttpJson::RequestError.new("malformed:#{arg_name}:#{msg}:")
  end

  # = = = = = = = = = = = = = = = =

  def manifest
    args['manifest']
  end

  # - - - - - - - - - - - - - - - -

  def id
    args['id']
  end

  def indexes
    args['indexes']
  end

  def index
    args['index']
  end

  def files
    args['files']
  end

  def now
    args['now']
  end

  def duration
    args['duration']
  end

  def stdout
    args['stdout']
  end

  def stderr
    args['stderr']
  end

  def status
    args['status']
  end

  def colour
    args['colour']
  end

end
