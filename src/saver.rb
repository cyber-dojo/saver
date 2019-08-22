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
    # Note: FileUtils.mkdir_p() does not tell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    stdout,stderr,r = Open3.capture3("mkdir -vp '#{name}'")
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def append(filename, content)
    make?(File.dirname(filename))
    File.open(filename, 'a') { |fd| fd.write(content) }
  end

  def write(filename, content)
    make?(File.dirname(filename))
    File.open(filename, 'w') { |fd| fd.write(content) }
  end

  def reads(filenames) # read() BatchMethod
    filenames.map{ |filename| read(filename) }
  end

  def read(filename)
    if File.file?(filename)
      File.open(filename, 'r') { |fd| fd.read }
    else
      nil
    end
  end

end
