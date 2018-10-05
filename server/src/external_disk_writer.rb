require_relative 'external_dir_writer'

class ExternalDiskWriter

  def initialize(externals)
    @externals = externals
  end

  def [](dir_name)
    ExternalDirWriter.new(@externals, dir_name)
  end

end