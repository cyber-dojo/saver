# frozen_string_literal: true

require 'fileutils'

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
    dirname = File.dirname(path_name(key))
    FileUtils.mkdir_p(dirname)
    mode = File::WRONLY | File::CREAT | File::EXCL
    File.open(path_name(key), mode) { |fd| fd.write(value) }
    true
  rescue Errno::EEXIST
    false
  end

  def append(key, value)
    mode = File::WRONLY | File::APPEND
    File.open(path_name(key), mode) { |fd| fd.write(value) }
    true
  rescue Errno::ENOENT
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    mode = File::RDONLY
    File.open(path_name(key), mode) { |fd| fd.read }
  rescue Errno::ENOENT
    nil
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

end
