# frozen_string_literal: true

require 'open3'

class Saver

  def initialize(root_dir = 'cyber-dojo')
    @root_dir = root_dir
  end

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
  # deprecated

  def batch(command); batch_run(command); end
  def batch_until_true(commands); batch_run_until_true(commands); end
  def batch_until_false(commands); batch_run_until_false(commands); end

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
  rescue Errno::ENOENT # file does not exist
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    mode = File::RDONLY
    File.open(path_name(key), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.read
    }
  rescue Errno::ENOENT, # file does not exist
         Errno::EISDIR  # file is a dir!
    false
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
    when CREATE_COMMAND_NAME then create(*args)
    when EXISTS_COMMAND_NAME then exists?(*args)
    when WRITE_COMMAND_NAME  then write(*args)
    when APPEND_COMMAND_NAME then append(*args)
    when READ_COMMAND_NAME   then read(*args)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batch-methods

  def batch_assert(commands)
    batch_run_until(commands) {|r,index|
      if r
        false
      else
        raise "commands[#{index}] != true"
      end
    }
  end

  def batch_run(commands)
    batch_run_until(commands) {|r| r === :never}
  end

  def batch_run_until_true(commands)
    batch_run_until(commands) {|r| r}
  end

  def batch_run_until_false(commands)
    batch_run_until(commands) {|r| !r}
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

  def path_name(key)
    File.join('', @root_dir, key)
  end

end
