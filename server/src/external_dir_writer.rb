require 'open3'

class ExternalDirWriter

  def initialize(name)
    @name = name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  attr_reader :name

  def exists?
    File.directory?(name)
  end

  def make
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
    open(filename, 'a') { |fd| fd.write(content) }
  end

  def write(filename, content)
    open(filename, 'w') { |fd| fd.write(content) }
  end

  def read(filename)
    open(filename, 'r') { |fd| fd.read }
  end

  private

  def open(filename, mode)
    File.open(pathed(filename), mode) { |fd| yield fd }
  end

  def pathed(filename)
    File.join(name, filename)
  end

end
