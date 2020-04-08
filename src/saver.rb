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
    when DIR_MAKE_COMMAND_NAME    then create(*args)
    when DIR_EXISTS_COMMAND_NAME  then exists?(*args)
    when FILE_CREATE_COMMAND_NAME then write(*args)
    when FILE_APPEND_COMMAND_NAME then append(*args)
    when FILE_READ_COMMAND_NAME   then read(*args)
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

  def batch(command); run_all(command); end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: make private

  def exists?(key)
    Dir.exist?(path_name(key))
  end

  def create(key)
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

  def write(key, value)
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

  def append(key, value)
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

  def read(key)
    mode = File::RDONLY
    File.open(path_name(key), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.read
    }
  rescue Errno::EISDIR, # file is a dir!,
         Errno::ENOENT  # file does not exist

    false
  end

  private

  DIR_EXISTS_COMMAND_NAME = 'exists?'
  DIR_MAKE_COMMAND_NAME = 'create'

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

  def path_name(key)
    File.join('', @root_dir, key)
  end

end
