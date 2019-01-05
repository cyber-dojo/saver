require_relative 'external_disk'
require_relative 'external_mapper'
require_relative 'grouper'
require_relative 'singler'
require_relative 'env'
require_relative 'id_validator'

class Externals

  def disk
    @disk ||= ExternalDisk.new
  end

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def singler
    @singler ||= Singler.new(disk)
  end

  def env
    @sha ||= Env.new
  end

  def id_validator
    @id_validator ||= IdValidator.new(self)
  end

  def mapper
    @ported ||= ExternalMapper.new
  end

end
