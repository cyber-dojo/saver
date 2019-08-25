require_relative 'env'
require_relative 'grouper'
require_relative 'id_validator'
require_relative 'kata_id_generator'
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
    @singler ||= Singler.new(self)
  end

  def http
    @http ||= Net::HTTP
  end

  def env
    @sha ||= Env.new
  end

  def kata_id_generator
    @kata_id_generator ||= KataIdGenerator.new(self)
  end

  def id_validator
    @id_validator ||= IdValidator.new(self)
  end

end
