# frozen_string_literal: true

require 'open3'

class Saver

  def sha
    ENV['SHA']
  end

  def ready?
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?(key)
    Dir.exist?(path_name(key))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
    path = path_name(key)
    if make_dir?(dir_name(key)) || !File.exist?(path)
      File.open(path, 'w') { |fd| fd.write(value) }
      true
    else
      false
    end
  end

  def append(key, value)
    path = path_name(key)
    if File.exist?(path)
      File.open(path, 'a') { |fd| fd.write(value) }
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    path = path_name(key)
    if File.file?(path)
      File.open(path, 'r') { |fd| fd.read }
    else
      nil
    end
  end

  def batch_read(keys)
    keys.map { |key| read(key) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def batch_until_false(commands)
    batch(commands) { |result| !result }
  end

  def batch_until_true(commands)
    batch(commands) { |result| result }
  end

  private

  def batch(commands, &block)
    results = []
    commands.each do |command|
      name,*args = command
      result = case name
      when 'exists?' then exists?(*args)
      when 'write'   then write(*args)
      when 'append'  then append(*args)
      when 'read'    then read(*args)
      #else raise...
      end
      results << result
      if block.call(result)
        break
      end
    end
    results
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', 'cyber-dojo', key)
  end

  def dir_name(key)
    File.dirname(path_name(key))
  end

  def file_name(key)
    File.basename(path_name(key))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def make_dir?(path)
    # Returns true iff path does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    #   -p creates intermediate dirs as required.
    #   -v verbose mode, output each dir actually made
    command = "mkdir -vp '#{path}'"
    stdout,stderr,r = Open3.capture3(command)
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

end
