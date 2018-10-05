
class ExternalDirWriter

  def initialize(externals, name)
    @externals = externals
    @name = name
  end

  attr_reader :name

  def make
    # Can't find a Ruby library method allowing you to do a
    # mkdir_p and-know-if-a-dir-was-created-or-not.
    # Note: FileUtils.mkdir_p() does not tell.
    # So using shell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    output,_exit_status = shell.exec("mkdir -vp #{name}")
    output != ''
  end

  def exists?
    File.directory?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(filename, content)
    File.open(pathed(filename), 'w') { |fd| fd.write(content) }
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