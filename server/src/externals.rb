require_relative 'external_disk_writer'
require_relative 'grouper'
require_relative 'singler'
require_relative 'image'

class Externals

  def disk
    @disk ||= ExternalDiskWriter.new
  end

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def singler
    @singler ||= Singler.new(disk)
  end

  def image
    @image ||= Image.new(disk)
  end

end
