# frozen_string_literal: true
require_relative 'http_json/request_error'
require_relative 'lib/json_adapter'

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
  rescue JSON::ParserError
  #rescue Oj::ParseError
    fail HttpJson::RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path, externals)
    prober = externals.prober
    disk = externals.disk
    args = case path
    when '/sha'     then [prober,'sha']
    when '/ready'   then [prober,'ready?']
    when '/alive'   then [prober,'alive?']

    when '/assert'  then [disk,'assert',command]
    when '/run'     then [disk,'run'   ,command]

    when '/assert_all'      then [disk,'assert_all'     ,commands]
    when '/run_all'         then [disk,'run_all'        ,commands]
    when '/run_until_true'  then [disk,'run_until_true' ,commands]
    when '/run_until_false' then [disk,'run_until_false',commands]

    else
      fail HttpJson::RequestError, 'unknown path'
    end

    target = args.shift
    name = args.shift
    if args != []
      args = args[0]
    end
    args = Hash[args.map{ |key,value| [key.to_sym, value] }]
    [target, name, args]
  end

  private

  include JsonAdapter

  attr_reader :args

  def command
    well_formed_command
  end

  def commands
    well_formed_commands
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
    { "command" => command }
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
    commands.each.with_index do |command, index|
      unless command.is_a?(Array)
        fail malformed("commands[#{index}]", "!Array (#{command.class.name})")
      end
      fail_unless_well_formed_command(command,"s[#{index}]")
    end
    { "commands" => commands }
  end

  # - - - - - - - - - - - - - - -

  def fail_unless_well_formed_command(command, index)
    name = command[0]
    unless name.is_a?(String)
      fail malformed("command#{index}[0]", "!String (#{name.class.name})")
    end
    case name
    when 'dir_exists?' then fail_unless_well_formed_args(command,index,'dirname')
    when 'dir_make'    then fail_unless_well_formed_args(command,index,'dirname')
    when 'file_create' then fail_unless_well_formed_args(command,index,'filename','content')
    when 'file_append' then fail_unless_well_formed_args(command,index,'filename','content')
    when 'file_read'   then fail_unless_well_formed_args(command,index,'filename')
    else
      fail malformed("command#{index}", "Unknown (#{name})")
    end
  end

  # - - - - - - - - - - - - - - -

  def fail_unless_well_formed_args(command, index, *arg_names)
    name,*args = command
    arity = arg_names.size
    unless args.size === arity
      fail malformed("command#{index}", "#{name}!#{args.size}")
    end
    arity.times do |n|
      arg = args[n]
      arg_name = arg_names[n]
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
