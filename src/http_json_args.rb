# frozen_string_literal: true

require_relative 'http_json/request_error'
require_relative 'oj_adapter'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(body)
    if body === ''
      body = '{}'
    end
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
    args = case path
    when '/sha'     then [saver,'sha']
    when '/ready'   then [saver,'ready?']
    when '/alive'   then [saver,'alive?']

    when '/assert'  then [saver,'assert',command]
    when '/run'     then [saver,'run'   ,command]

    when '/assert_all'      then [saver,'assert_all'     ,commands]
    when '/run_all'         then [saver,'run_all'        ,commands]
    when '/run_until_true'  then [saver,'run_until_true' ,commands]
    when '/run_until_false' then [saver,'run_until_false',commands]

    # deprecated
    when '/create'  then [saver,'create'  ,key]
    when '/exists'  then [saver,'exists?' ,key]
    when '/write'   then [saver,'write'   ,key,value]
    when '/append'  then [saver,'append'  ,key,value]
    when '/read'    then [saver,'read'    ,key]
    when '/batch'   then [saver,'batch'   ,commands]

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

  def command
    well_formed_command
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

  # - - - - - - - - - - - - - - -

  def well_formed_command
    arg_name = 'command'
    unless args.has_key?(arg_name)
      fail missing(arg_name)
    end
    command = args[arg_name]
    unless command.is_a?(Array)
      fail malformed(arg_name, "!Array (#{command.class.name})")
    end
    fail_unless_well_formed_command(command,'')
    command
  end

  # - - - - - - - - - - - - - - -

  def well_formed_commands
    arg_name = 'commands'
    unless args.has_key?(arg_name)
      fail missing(arg_name)
    end
    commands = args[arg_name]
    unless commands.is_a?(Array)
      fail malformed(arg_name, "!Array (#{commands.class.name})")
    end
    commands.each.with_index do |command,index|
      unless command.is_a?(Array)
        fail malformed("commands[#{index}]", "!Array (#{command.class.name})")
      end
      fail_unless_well_formed_command(command,"s[#{index}]")
    end
    commands
  end

  # - - - - - - - - - - - - - - -

  def fail_unless_well_formed_command(command,index)
    name = command[0]
    unless name.is_a?(String)
      fail malformed("command#{index}[0]", "!String (#{name.class.name})")
    end
    case name
    when 'create'  then fail_unless_well_formed_args(command,index,1)
    when 'exists?' then fail_unless_well_formed_args(command,index,1)
    when 'write'   then fail_unless_well_formed_args(command,index,2)
    when 'append'  then fail_unless_well_formed_args(command,index,2)
    when 'read'    then fail_unless_well_formed_args(command,index,1)
    else
      fail malformed("command#{index}", "Unknown (#{name})")
    end
  end

  # - - - - - - - - - - - - - - -

  def fail_unless_well_formed_args(command,index,arity)
    name,*args = command
    unless args.size === arity
      fail malformed("command#{index}", "#{name}!#{args.size}")
    end
    args_names = [ 'key', 'value' ]
    arity.times do |n|
      arg = args[n]
      arg_name = args_names[n]
      unless arg.is_a?(String)
        fail malformed("command#{index}", "#{name}(#{arg_name}!=String)")
      end
    end
  end

  # - - - - - - - - - - - - - - - -

  def missing(arg_name)
    HttpJson::RequestError.new("missing:#{arg_name}:")
  end

  def malformed(arg_name, msg)
    HttpJson::RequestError.new("malformed:#{arg_name}:#{msg}:")
  end

end
