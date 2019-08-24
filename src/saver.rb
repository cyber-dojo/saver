# frozen_string_literal: true

require 'open3'

class Saver

  def exist?(name)
    File.directory?(name)
  end

  def make?(name)
    # Returns true iff the dir does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    #   -p creates intermediate dirs as required.
    #   -v verbose mode, output each dir actually made
    stdout,stderr,r = Open3.capture3("mkdir -vp '#{name}'")
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(filename, content)
    if Dir.exist?(File.dirname(filename)) && !File.exist?(filename)
      File.open(filename, 'w') { |fd| fd.write(content) }
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def append(filename, content)
    if File.exist?(filename)
      File.open(filename, 'a') { |fd| fd.write(content) }
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(filename)
    if File.file?(filename)
      File.open(filename, 'r') { |fd| fd.read }
    else
      nil
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def reads(filenames) # read() BatchMethod
    filenames.map{ |filename| read(filename) }
  end

end
