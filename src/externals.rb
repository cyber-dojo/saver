require_relative 'external_disk_writer'
require_relative 'grouper'
require_relative 'singler'
#require_relative 'storer_service'
require_relative 'image'
require_relative 'id_validator'

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

  #def storer
  #  @storer ||= StorerService.new
  #end

  def image
    @image ||= Image.new(disk)
  end

  def id_validator
    @id_validator ||= IdValidator.new(self)
  end

end
