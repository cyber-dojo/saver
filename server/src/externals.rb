require_relative 'grouper'
require_relative 'external_disk_writer'
require_relative 'external_id_generator'
require_relative 'external_id_validator'
require_relative 'external_singler'

class Externals

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def singler
    @singler ||= ExternalSingler.new
  end

  def id_generator
    @id_generator ||= ExternalIdGenerator.new(self)
  end

  def id_validator
    @id_validator ||= ExternalIdValidator.new(self)
  end
  def id_validator=(arg)
    @id_validator = arg
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

end
