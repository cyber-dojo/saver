# frozen_string_literal: true
require_relative '../src/saver_service'
require_relative '../src/saver_exception'

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
    [DIR_EXISTS_COMMAND_NAME,key]
  end

  def dir_make_command(key)
    [DIR_MAKE_COMMAND_NAME,key]
  end

  def file_create_command(key,value)
    [FILE_CREATE_COMMAND_NAME,key,value]
  end

  def file_append_command(key,value)
    [FILE_APPEND_COMMAND_NAME,key,value]
  end

  def file_read_command(key)
    [FILE_READ_COMMAND_NAME,key]
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
    when 'create'  then create(*args)
    when 'exists?' then exists?(*args)
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
  # TODO: make private

  def exists?(key)
    raise_unless_key_is_a_String('exists?',key)
    dir?(path_name(key))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def create(key)
    raise_unless_key_is_a_String('create',key)
    path = path_name(key)
    if dir?(path) || file?(path)
      false
    else
      @@dirs[path] = true
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
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

  def append(key, value)
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

  def read(key)
    @@files[path_name(key)] || false
  end

  private

  DIR_EXISTS_COMMAND_NAME = 'exists?'
  DIR_MAKE_COMMAND_NAME   = 'create'

  FILE_CREATE_COMMAND_NAME  = 'write'
  FILE_APPEND_COMMAND_NAME = 'append'
  FILE_READ_COMMAND_NAME   = 'read'

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

  def raise_assert_exception(command)
    message = {
      path:"/#{@origin}",
      body:{'command':command}.to_json,
      class:'SaverService',
      message:'command != true'
    }.to_json
    raise SaverException,message
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
      raise SaverException,message
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
      raise SaverException,message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', 'cyber-dojo', key)
  end

  def dir?(key)
    @@dirs.has_key?(key)
  end

  def file?(key)
    @@files.has_key?(key)
  end

end
