
class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)                   # eg '0215AFADCB'
    args = []
    args << grouper.path
    args << outer(id)              # eg '01
    args << inner(id)[0..3] + '**' # eg '15AF**'
    path = File.join(*args)        # eg .../01/15AF**
    matched = Dir.glob(path).select{ |name|
      File.directory?(name)
    }
    matched == []
  end

  private

  def outer(id)
    id[0..1]
  end

  def inner(id)
    id[2..-1]
  end

  def grouper
    @externals.grouper
  end

end
