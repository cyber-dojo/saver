require_relative 'external_dir_writer'

class ExternalDiskWriter

  def [](id, index=nil)
    ExternalDirWriter.new(id, index)
  end

end