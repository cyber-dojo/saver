# frozen_string_literal: true
require_relative 'test_base'
require_source 'saver_service'

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
    @path = 'assert'
    @body = {command:command}
    result = run(command)
    if result
      result
    else
      raise_fake_exception('command != true')
    end
  end

  def run(command)
    @path ||= 'run'
    @body ||= {command:command}
    raise_unless_well_formed_command(command)
    name,*args = command
    case name
    when DIR_EXISTS_COMMAND_NAME  then dir_exists?(*args)
    when DIR_MAKE_COMMAND_NAME    then dir_make(*args)
    when FILE_CREATE_COMMAND_NAME then file_create(*args)
    when FILE_APPEND_COMMAND_NAME then file_append(*args)
    when FILE_READ_COMMAND_NAME   then file_read(*args)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batched

  def assert_all(commands)
    @path = 'assert_all'
    @body = {commands:commands}
    run_until(commands) {|r,index|
      if r
        false
      else
        message = "commands[#{index}] != true"
        raise_fake_exception(message)
      end
    }
  end

  def run_all(commands)
    @path = 'run_all'
    @body = {commands:commands}
    run_until(commands) {|r| r === :never}
  end

  def run_until_true(commands)
    @path = 'run_until_true'
    @body = {commands:commands}
    run_until(commands) {|r| r}
  end

  def run_until_false(commands)
    @path = 'run_until_false'
    @body = {commands:commands}
    run_until(commands) {|r| !r}
  end

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
    dir?(path_name(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_make(dirname)
    path = path_name(dirname)
    if dir?(path) || file?(path)
      false
    else
      @@dirs[path] = true
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_create(filename, content)
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
    @@files[path_name(filename)] || false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # exception helpers

  def raise_fake_exception(message)
    raise SaverService::Error,{
      path:"/#{@path}",
      body:@body.to_json,
      class:'SaverService',
      message:message
    }.to_json
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def raise_unless_well_formed_commands(commands)
    unless commands.is_a?(Array)
      message = malformed('commands', "!Array (#{commands.class.name})")
      raise_fake_exception(message)
    end
    commands.each.with_index do |command,index|
      unless command.is_a?(Array)
        message = malformed("commands[#{index}]", "!Array (#{command.class.name})")
        raise_fake_exception(message)
      end
      raise_unless_well_formed_command(command, "s[#{index}]")
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def raise_unless_well_formed_command(command, index='')
    unless command.is_a?(Array)
      message = malformed("command#{index}", "!Array (#{command.class.name})")
      raise_fake_exception(message)
    end
    name = command[0]
    case name
    when 'dir_exists?' then raise_unless_well_formed_args(command,index,'dirname')
    when 'dir_make'    then raise_unless_well_formed_args(command,index,'dirname')
    when 'file_create' then raise_unless_well_formed_args(command,index,'filename','content')
    when 'file_append' then raise_unless_well_formed_args(command,index,'filename','content')
    when 'file_read'   then raise_unless_well_formed_args(command,index,'filename')
    else
      message = "malformed:command#{index}:Unknown (#{name}):"
      raise_fake_exception(message)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def raise_unless_well_formed_args(command,index,*arg_names)
    name,*args = command
    arity = arg_names.size
    unless args.size === arity
      message = malformed("command#{index}", "#{name}!#{args.size}")
      raise_fake_exception(message)
    end
    arity.times do |n|
      arg = args[n]
      arg_name = arg_names[n]
      unless arg.is_a?(String)
        message = malformed("command#{index}", "#{name}(#{arg_name}!=String)")
        raise_fake_exception(message)
      end
    end
  end

  def malformed(arg_name, msg)
    RuntimeError.new("malformed:#{arg_name}:#{msg}:")
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
