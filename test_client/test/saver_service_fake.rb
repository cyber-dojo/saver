# frozen_string_literal: true
require_relative '../src/saver_service'

class SaverServiceFake

  def initialize
    @@dirs = {}
    @@files = {}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def alive?
    true
  end

  def ready?
    true
  end

  def sha
    '71333653be9b1ca2c31f83810d4e6f128817deac'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  def dir_exists_command(dirname)
    SaverService.new.dir_exists_command(dirname)
  end

  def dir_make_command(dirname)
    SaverService.new.dir_make_command(dirname)
  end

  def file_create_command(filename, content)
    SaverService.new.file_create_command(filename, content)
  end

  def file_append_command(filename, content)
    SaverService.new.file_append_command(filename, content)
  end

  def file_read_command(filename)
    SaverService.new.file_read_command(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # singular

  def assert(command)
    @origin = 'assert'
    result = run(command)
    if result
      result
    else
      raise_command_exception(command, 'command != true')
    end
  end

  def run(command)
    @origin ||= 'run'
    raise_unless_well_formed_command(command)
    name,*args = command
    case name
    when DIR_EXISTS_COMMAND_NAME  then dir_exists?(*args)
    when DIR_MAKE_COMMAND_NAME    then dir_make(*args)
    when FILE_CREATE_COMMAND_NAME then file_create(*args)
    when FILE_APPEND_COMMAND_NAME then file_append(*args)
    when FILE_READ_COMMAND_NAME   then file_read(*args)
    # deprecated, used by batch()
    when 'exists?' then exists?(*args)
    when 'create'  then create(*args)
    when 'write'   then write(*args)
    when 'append'  then append(*args)
    when 'read'    then read(*args)

    else
      message = "malformed:command:Unknown (#{name}):"
      raise_command_exception(command, message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batched

  def assert_all(commands)
    @origin = 'assert_all'
    run_until(commands) {|r,index|
      if r
        false
      else
        message = "commands[#{index}] != true"
        raise_commands_exception(commands, message)
      end
    }
  end

  def run_all(commands)
    #@origin = 'run_all'
    run_until(commands) {|r| r === :never}
  end

  def run_until_true(commands)
    #@origin = 'run_until_true'
    run_until(commands) {|r| r}
  end

  def run_until_false(commands)
    #@origin = 'run_until_false'
    run_until(commands) {|r| !r}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # deprecated

  def exists?(key); dir_exists?(key); end
  def create(key); dir_make(key); end
  def write(key,value); file_create(key,value); end
  def append(key, value); file_append(key, value); end
  def read(key); file_read(key); end
  def batch(commands); run_all(commands); end

  private

  DIR_EXISTS_COMMAND_NAME = 'dir_exists?'
  DIR_MAKE_COMMAND_NAME   = 'dir_make'

  FILE_CREATE_COMMAND_NAME = 'file_create'
  FILE_APPEND_COMMAND_NAME = 'file_append'
  FILE_READ_COMMAND_NAME   = 'file_read'

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_until(commands, &block)
    raise_unless_well_formed_commands(commands)
    results = []
    commands.each.with_index(0) do |command,index|
      result = run(command)
      results << result
      break if block.call(result,index)
    end
    results
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  def dir_exists?(dirname)
    raise_unless_String('dir_exists?','dirname',0,dirname)
    dir?(path_name(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_make(dirname)
    raise_unless_String('dir_make','dirname',0,dirname)
    path = path_name(dirname)
    if dir?(path) || file?(path)
      false
    else
      @@dirs[path] = true
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_create(filename, content)
    raise_unless_String('file_create','filename',0,filename,content)
    raise_unless_String('file_create','content',1,filename,content)
    path = path_name(filename)
    if dir?(File.dirname(path)) && !file?(path)
      @@files[path] = content
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_append(filename, content)
    raise_unless_String('file_append','filename',0,filename,content)
    raise_unless_String('file_append','content',1,filename,content)
    path = path_name(filename)
    if dir?(File.dirname(path)) && file?(path)
      @@files[path] += content
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_read(filename)
    raise_unless_String('file_read','filename',0,filename)
    @@files[path_name(filename)] || false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # exception helpers

  def raise_command_exception(command, message)
    message = {
      path:"/#{@origin}",
      body:{'command':command}.to_json,
      class:'SaverService',
      message:message
    }.to_json
    raise SaverService::Error,message
  end

  def raise_commands_exception(commands, message)
    message = {
      path:'/assert_all',
      body:{'commands':commands}.to_json,
      class:'SaverService',
      message:message,
    }.to_json
    raise SaverService::Error,message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def raise_unless_well_formed_commands(commands)
    unless commands.is_a?(Array)
      message = malformed('commands', "!Array (#{commands.class.name})")
      raise_commands_exception(commands, message)
    end
    commands.each.with_index do |command,index|
      unless command.is_a?(Array)
        message = malformed("commands[#{index}]", "!Array (#{command.class.name})")
        raise_commands_exception(commands, message)
      end
      raise_unless_well_formed_command(command, "s[#{index}]")
    end
  end

  def raise_unless_well_formed_command(command, index='')
    unless command.is_a?(Array)
      message = malformed("command#{index}", "!Array (#{command.class.name})")
      raise_command_exception(command, message)
    end
    name = command[0]
    case name
    when 'dir_exists?' then raise_unless_well_formed_args(command,index,'dirname')
    when 'dir_make'    then raise_unless_well_formed_args(command,index,'dirname')
    when 'file_create' then raise_unless_well_formed_args(command,index,'filename','content')
    when 'file_append' then raise_unless_well_formed_args(command,index,'filename','content')
    when 'file_read'   then raise_unless_well_formed_args(command,index,'filename')
    end
  end

  def raise_unless_well_formed_args(command,index,*arg_names)
    name,*args = command
    arity = arg_names.size
    unless args.size === arity
      message = malformed("command#{index}", "#{name}!#{args.size}")
      raise_command_exception(command, message)
    end
    arity.times do |n|
      arg = args[n]
      arg_name = arg_names[n]
      unless arg.is_a?(String)
        message = malformed("command#{index}", "#{name}(#{arg_name}!=String)")
        raise_command_exception(command, message)
      end
    end
  end

  def malformed(arg_name, msg)
    RuntimeError.new("malformed:#{arg_name}:#{msg}:")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def raise_unless_String(command, arg_name, index, *args)
    arg = args[index]
    unless arg.is_a?(String)
      message = {
        path:"/#{@origin}",
        body:{'command':[command,*args]}.to_json,
        class:'SaverService',
        message:"malformed:command:#{command}(#{arg_name}!=String):"
      }.to_json
      raise SaverService::Error,message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(s)
    File.join('', 'cyber-dojo', s)
  end

  def dir?(dirname)
    @@dirs.has_key?(dirname)
  end

  def file?(filename)
    @@files.has_key?(filename)
  end

end
