# frozen_string_literal: true

require 'open3'

class ExternalDisk

  def exist?(name)
    File.directory?(name)
  end

  def make?(name)
    # Returns true iff the dir does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    # Note: FileUtils.mkdir_p() does not tell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    stdout,stderr,r = Open3.capture3("mkdir -vp '#{name}'")
    stdout != '' && stderr == '' && r.exitstatus == 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def append(filename, content)
    make?(File.dirname(filename))
    open(filename, 'a') { |fd| fd.write(content) }
  end

  def write(filename, content)
    make?(File.dirname(filename))
    open(filename, 'w') { |fd| fd.write(content) }
  end

  def read(arg)
    if arg.is_a?(Array)
      arg.map{ |filename| read_one(filename) }
    else
      read_one(arg)
    end
  end

  private

  def read_one(filename)
    if File.file?(filename)
      open(filename, 'r') { |fd| fd.read }
    else
      nil
    end
  end

  def open(filename, mode)
    File.open(filename, mode) { |fd| yield fd }
  end

end
