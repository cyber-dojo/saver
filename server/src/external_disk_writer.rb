require_relative 'external_dir_writer'

class ExternalDiskWriter

  def [](name)
    ExternalDirWriter.new(name)
  end

end