require_relative 'id_splitter'

class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)             # eg '0215AFADCB'
    return false if id.upcase.include?('L')
    args = []
    args << grouper.path
    args << outer(id)        # eg '01
    args << inner(id)[0..3]  # eg '15AF**'
    disk[File.join(*args)].completions == []
  end

  private

  include IdSplitter

  def grouper
    @externals.grouper
  end

  def disk
    @externals.disk
  end

end
