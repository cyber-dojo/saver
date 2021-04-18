# frozen_string_literal: true
require_relative 'require_source'
require_source 'external/disk'

class DiskFake

  def initialize(externals)
    @externals = externals
    @@dirs ||= {}
    @@files ||= {}
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  def dir_make_command(dir_name)
    disk.dir_make_command(dir_name)
  end

  def dir_exists_command(dir_name)
    disk.dir_exists_command(dir_name)
  end

  def file_create_command(filename, content)
    disk.file_create_command(filename, content)
  end

  def file_append_command(filename, content)
    disk.file_append_command(filename, content)
  end

  def file_read_command(filename)
    disk.file_read_command(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # primitives

  def assert(command:)
    result = run(command:command)
    if result
      result
    else
      raise "command != true"
    end
  end

  def run(command:)
    name,*args = command
    case name
    when 'dir_make'    then dir_make(*args)
    when 'dir_exists?' then dir_exists?(*args)
    when 'file_create' then file_create(*args)
    when 'file_append' then file_append(*args)
    when 'file_read'   then file_read(*args)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # batches

  def assert_all(commands:)
    run_until(commands) {|r,index|
      if r
        false
      else
        raise SaverService::Error, "commands[#{index}] != true"
      end
    }
  end

  def run_all(commands:)
    run_until(commands) {|r| r === :never }
  end

  def run_until_true(commands:)
    run_until(commands) {|r| r}
  end

  def run_until_false(commands:)
    run_until(commands) {|r| !r}
  end

  private

  def run_until(commands, &block)
    results = []
    commands.each.with_index(0) do |command,index|
      result = run(command:command)
      results << result
      break if block.call(result,index)
    end
    results
  end

  # - - - - - - - - - - - - - - - - - -

  def dir_exists?(key)
    dir?(path_name(key))
  end

  def dir_make(key)
    if dir_exists?(key)
      false
    else
      @@dirs[path_name(key)] = true
    end
  end

  def file_create(key,value)
    path = path_name(key)
    if dir?(File.dirname(path)) && !file?(path)
      @@files[path] = value
      true
    else
      false
    end
  end

  def file_append(key, value)
    path = path_name(key)
    if dir?(File.dirname(path)) && file?(path)
      @@files[path] += value
      true
    else
      false
    end
  end

  def file_read(key)
    @@files[path_name(key)] || false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', 'tmp', 'cyber-dojo', key)
  end

  def dir?(key)
    @@dirs.has_key?(key)
  end

  def file?(key)
    @@files.has_key?(key)
  end

  def disk
    External::Disk.new() # For the commands only
  end

end
