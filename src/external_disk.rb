require_relative 'external_dir'

class ExternalDisk

  def [](name)
    ExternalDir.new(name)
  end

end
