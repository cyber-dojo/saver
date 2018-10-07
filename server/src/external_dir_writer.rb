require 'open3'

class ExternalDirWriter

  def initialize(id, index)
    @id = id
    @index = index
  end

  def make
    # Returns true iff the dir does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    # Note: FileUtils.mkdir_p() does not tell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    stdout,stderr,r = Open3.capture3("mkdir -vp #{name}")
    stdout != '' && stderr == '' && r.exitstatus == 0
  end

  def exists?
    File.directory?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(filename, content)
    IO.write(pathed(filename), content)
  end

  def read(filename)
    IO.read(pathed(filename))
  end

  private

  def name
    # Using 2/2/2 split
    # See https://github.com/cyber-dojo/porter
    args = ['', 'grouper', 'ids', @id[0..1], @id[2..3], @id[4..5]]
    unless @index.nil?
      args << @index.to_s
    end
    File.join(*args)
  end

  def pathed(filename)
    File.join(name, filename)
  end

end