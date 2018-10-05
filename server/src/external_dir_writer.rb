
class ExternalDirWriter

  def initialize(externals, name)
    @externals = externals
    @name = name
  end

  attr_reader :name

  def make
    # Returns true iff the dir does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    # Note: FileUtils.mkdir_p() does not tell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    stdout,stderr,status = shell.exec("mkdir -vp #{name}")
    stdout != '' && stderr == '' && status == 0
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

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def completions
    Dir.glob(name + '**').select{ |complete|
      File.directory?(complete)
    }
  end

  private

  def shell
    @externals.shell
  end

  def pathed(entry)
    name + '/' + entry
  end

end