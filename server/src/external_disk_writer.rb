require_relative 'external_dir_writer'

class ExternalDiskWriter

  def initialize(externals)
    @externals = externals
  end

  def [](id, index=nil)
    ExternalDirWriter.new(@externals, id, index)
  end

end