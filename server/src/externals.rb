require_relative 'grouper'
require_relative 'external_disk_writer'
require_relative 'external_singler'

class Externals

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def singler
    @singler ||= ExternalSingler.new
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

end
