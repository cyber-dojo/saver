require_relative 'id_splitter'

class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)                   # eg '0215AFADCB'
    return false if id.upcase.include?('L')
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

  include IdSplitter

  def grouper
    @externals.grouper
  end

end
