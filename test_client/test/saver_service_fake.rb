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

  def exists_command(key)
    [EXISTS_COMMAND_NAME,key]
  end

  def create_command(key)
    [CREATE_COMMAND_NAME,key]
  end

  def write_command(key,value)
    [WRITE_COMMAND_NAME,key,value]
  end

  def append_command(key,value)
    [APPEND_COMMAND_NAME,key,value]
  end

  def read_command(key)
    [READ_COMMAND_NAME,key]
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

  #def batch_assert(commands)

  def batch_run(commands)
    batch_run_until(commands) {|r| r === :never}
  end

  #def batch_run_until_true(commands)
  #def batch_run_until_false(commands)

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: make private

  def exists?(key)
    raise_if_bad_key('exists?',key)
    dir?(path_name(key))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def create(key)
    raise_if_bad_key('create',key)
    path = path_name(key)
    if dir?(path) || file?(path)
      false
    else
      @@dirs[path] = true
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
    raise_if_bad_key('write',key,value)
    raise_if_bad_value('write',key,value)
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
    raise_if_bad_key('append',key,value)
    raise_if_bad_value('append',key,value)
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

  EXISTS_COMMAND_NAME = 'exists?'
  CREATE_COMMAND_NAME = 'create'
  WRITE_COMMAND_NAME  = 'write'
  APPEND_COMMAND_NAME = 'append'
  READ_COMMAND_NAME   = 'read'

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def batch_run_until(commands, &block)
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

  def raise_if_bad_key(command,*args)
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

  def raise_if_bad_value(command,key,value)
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
