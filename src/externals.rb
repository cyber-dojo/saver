require_relative 'env'
require_relative 'external_mapper'
require_relative 'grouper'
require_relative 'id_validator'
require_relative 'saver'
require_relative 'singler'
require 'net/http'

class Externals

  def saver
    @saver ||= Saver.new
  end

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def singler
    @singler ||= Singler.new(saver)
  end

  def http
    @http ||= Net::HTTP
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
