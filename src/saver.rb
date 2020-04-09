# frozen_string_literal: true

require 'open3'

class Saver

  def initialize(root_dir = 'cyber-dojo')
    @root_dir = root_dir
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    ENV['SHA']
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
    result = run(command)
    if result
      result
    else
      raise "command != true"
    end
  end

  def run(command)
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

  def assert_all(commands)
    run_until(commands) {|r,index|
      if r
        false
      else
        raise "commands[#{index}] != true"
      end
    }
  end

  def run_all(commands)
    run_until(commands) {|r| r === :never}
  end

  def run_until_true(commands)
    run_until(commands) {|r| r}
  end

  def run_until_false(commands)
    run_until(commands) {|r| !r}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: deprecated

  def batch(commands); run_all(commands); end
  def exists?(key); dir_exists?(key); end
  def create(key); dir_make(key); end
  def write(key,value); file_create(key,value); end
  def append(key,value); file_append(key,value); end
  def read(key); file_read(key); end

  private

  DIR_EXISTS_COMMAND_NAME = 'dir_exists?'
  DIR_MAKE_COMMAND_NAME   = 'dir_make'

  FILE_CREATE_COMMAND_NAME = 'file_create'
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
    Dir.exist?(path_name(key))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_make(key)
    # Returns true iff key's dir does not already exist and
    # is made. Can't find a Ruby library method for this
    # (FileUtils.mkdir_p does not tell) so using shell.
    #   -p creates intermediate dirs as required.
    #   -v verbose mode, output each dir actually made
    command = "mkdir -vp '#{path_name(key)}'"
    stdout,stderr,r = Open3.capture3(command)
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_create(key, value)
    # Errno::ENOSPC (no space left on device) will
    # be caught by RackDispatcher --> status=500
    mode = File::WRONLY | File::CREAT | File::EXCL
    File.open(path_name(key), mode) { |fd|
      fd.write(value)
    }
    true
  rescue Errno::ENOENT, # dir does not exist
         Errno::EEXIST  # file already exists
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_append(key, value)
    # Errno::ENOSPC (no space left on device) will
    # be caught by RackDispatcher --> status=500
    mode = File::WRONLY | File::APPEND
    File.open(path_name(key), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.write(value)
    }
    true
  rescue Errno::EISDIR, # file is a dir!
         Errno::ENOENT  # file does not exist
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_read(key)
    mode = File::RDONLY
    File.open(path_name(key), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.read
    }
  rescue Errno::EISDIR, # file is a dir!,
         Errno::ENOENT  # file does not exist

    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', @root_dir, key)
  end

end
