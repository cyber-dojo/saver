require_relative 'env'
require_relative 'grouper'
require_relative 'group_id_generator'
require_relative 'katas'
require_relative 'kata_id_generator'
require_relative 'saver'
require 'net/http'

class Externals

  def saver
    @saver ||= Saver.new
  end

  def grouper
    @grouper ||= Grouper.new(self)
  end

  def katas
    @katas ||= Katas.new(self)
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

  def group_id_generator
    @group_id_generator ||= GroupIdGenerator.new(self)
  end

end
