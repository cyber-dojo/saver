require_relative 'env'
require_relative 'external_disk'
require_relative 'external_mapper'
require_relative 'grouper'
require_relative 'id_validator'
require_relative 'singler'
require 'net/http'

class Externals

  def disk
    @disk ||= ExternalDisk.new
  end
  def disk=(obj)
    @disk = obj
  end

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def http
    @http ||= Net::HTTP
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
    @ported ||= ExternalMapper.new(self)
  end

end
