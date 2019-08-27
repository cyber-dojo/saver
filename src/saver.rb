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
    File.directory?(key)
  end

  def make?(key)
    # Returns true iff the dir does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    #   -p creates intermediate dirs as required.
    #   -v verbose mode, output each dir actually made
    stdout,stderr,r = Open3.capture3("mkdir -vp '#{key}'")
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
    if Dir.exist?(File.dirname(key)) && !File.exist?(key)
      File.open(key, 'w') { |fd| fd.write(value) }
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def append(key, value)
    if File.exist?(key)
      File.open(key, 'a') { |fd| fd.write(value) }
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    if File.file?(key)
      File.open(key, 'r') { |fd| fd.read }
    else
      nil
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def batch_read(keys)
    keys.map{ |key| read(key) }
  end

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
      when 'make?'   then make?(*args)
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

end
