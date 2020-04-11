# frozen_string_literal: true
require 'open3'

class Saver

  def initialize(root_dir = 'cyber-dojo')
    @root_dir = root_dir
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def alive?
    true
  end

  def ready?
    true
  end

  def sha
    ENV['SHA']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_exists_command(dirname)
    [DIR_EXISTS_COMMAND_NAME,dirname]
  end

  def dir_make_command(dirname)
    [DIR_MAKE_COMMAND_NAME,dirname]
  end

  def file_create_command(filename,content)
    [FILE_CREATE_COMMAND_NAME,filename,content]
  end

  def file_append_command(filename,content)
    [FILE_APPEND_COMMAND_NAME,filename,content]
  end

  def file_read_command(filename)
    [FILE_READ_COMMAND_NAME,filename]
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

  def dir_exists?(dirname)
    Dir.exist?(path_name(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def dir_make(dirname)
    # Returns true iff key's dir does not already exist and
    # is made. Can't find a Ruby library method for this
    # (FileUtils.mkdir_p does not tell) so using shell.
    #   -p creates intermediate dirs as required.
    #   -v verbose mode, output each dir actually made
    command = "mkdir -vp '#{path_name(dirname)}'"
    stdout,stderr,r = Open3.capture3(command)
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_create(filename, content)
    # Errno::ENOSPC (no space left on device) will
    # be caught by RackDispatcher --> status=500
    mode = File::WRONLY | File::CREAT | File::EXCL
    File.open(path_name(filename), mode) { |fd|
      fd.write(content)
    }
    true
  rescue Errno::ENOENT, # dir does not exist
         Errno::EEXIST  # file already exists
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_append(filename, content)
    # Errno::ENOSPC (no space left on device) will
    # be caught by RackDispatcher --> status=500
    mode = File::WRONLY | File::APPEND
    File.open(path_name(filename), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.write(content)
    }
    true
  rescue Errno::EISDIR, # file is a dir!
         Errno::ENOENT  # file does not exist
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def file_read(filename)
    mode = File::RDONLY
    File.open(path_name(filename), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.read
    }
  rescue Errno::EISDIR, # file is a dir!,
         Errno::ENOENT  # file does not exist

    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(s)
    File.join('', @root_dir, s)
  end

end
