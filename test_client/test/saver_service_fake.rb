# frozen_string_literal: true
require_relative '../src/saver_service'

class SaverServiceFake

  def initialize
    @@dirs = {}
    @@files = {}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    '71333653be9b1ca2c31f83810d4e6f128817deac'
  end

  def ready?
    true
  end

  def alive?
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_exists_command(key)
    SaverService.new.dir_exists_command(key)
  end

  def dir_make_command(key)
    SaverService.new.dir_make_command(key)
  end

  def file_create_command(key,value)
    SaverService.new.file_create_command(key,value)
  end

  def file_append_command(key,value)
    SaverService.new.file_append_command(key,value)
  end

  def file_read_command(key)
    SaverService.new.file_read_command(key)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # primitives

  def assert(command)
    @origin = 'assert'
    result = run(command)
    if result
      result
    else
      raise_assert_exception(command)
    end
  end

  def run(command)
    @origin ||= 'run'
    name,*args = command
    case name
    when DIR_EXISTS_COMMAND_NAME  then dir_exists?(*args)
    when DIR_MAKE_COMMAND_NAME    then dir_make(*args)
    when FILE_CREATE_COMMAND_NAME then file_create(*args)
    when FILE_APPEND_COMMAND_NAME then file_append(*args)
    when FILE_READ_COMMAND_NAME   then file_read(*args)
    # deprecated
    when 'exists?' then exists?(*args)
    when 'create'  then create(*args)
    when 'write'   then write(*args)
    when 'append'  then append(*args)
    when 'read'    then read(*args)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batches

  #def assert_all(commands)

  def run_all(commands)
    run_until(commands) {|r| r === :never}
  end

  #def run_until_true
  #def run_until_false

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: deprecated

  # def batch(commands); run_all(commands); end
  def exists?(key); dir_exists?(key); end
  def create(key); dir_make(key); end
  def write(key,value); file_create(key,value); end
  def append(key, value); file_append(key, value); end
  def read(key); file_read(key); end

  private

  DIR_EXISTS_COMMAND_NAME = 'dir_exists?'
  DIR_MAKE_COMMAND_NAME   = 'dir_make'

  FILE_CREATE_COMMAND_NAME = 'file_write'
  FILE_APPEND_COMMAND_NAME = 'file_append'
  FILE_READ_COMMAND_NAME   = 'file_read'

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_until(commands, &block)
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

  def dir_exists?(key)
    raise_unless_key_is_a_String('dir_exists?',key)
    dir?(path_name(key))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_make(key)
    raise_unless_key_is_a_String('dir_make',key)
    path = path_name(key)
    if dir?(path) || file?(path)
      false
    else
      @@dirs[path] = true
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_create(key, value)
    raise_unless_key_is_a_String('write',key,value)
    raise_unless_value_is_a_String('write',key,value)
    path = path_name(key)
    if dir?(File.dirname(path)) && !file?(path)
      @@files[path] = value
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_append(key, value)
    raise_unless_key_is_a_String('append',key,value)
    raise_unless_value_is_a_String('append',key,value)
    path = path_name(key)
    if dir?(File.dirname(path)) && file?(path)
      @@files[path] += value
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_read(key)
    raise_unless_key_is_a_String('read',key)
    @@files[path_name(key)] || false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # exception helpers

  def raise_assert_exception(command)
    message = {
      path:"/#{@origin}",
      body:{'command':command}.to_json,
      class:'SaverService',
      message:'command != true'
    }.to_json
    raise SaverService::Error,message
  end

  def raise_unless_key_is_a_String(command,*args)
    key = args[0]
    unless key.is_a?(String)
      message = {
        path:"/#{@origin}",
        body:{'command':[command,*args]}.to_json,
        class:'SaverService',
        message:"malformed:command:#{command}(key!=String):"
      }.to_json
      raise SaverService::Error,message
    end
  end

  def raise_unless_value_is_a_String(command,key,value)
    unless value.is_a?(String)
      message = {
        path:"/#{@origin}",
        body:{'command':[command,key,value]}.to_json,
        class:'SaverService',
        message:"malformed:command:#{command}(value!=String):"
      }.to_json
      raise SaverService::Error,message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', 'cyber-dojo', key.to_s)
  end

  def dir?(key)
    @@dirs.has_key?(key)
  end

  def file?(key)
    @@files.has_key?(key)
  end

end
