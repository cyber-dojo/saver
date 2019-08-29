#require_relative 'group_future'
require_relative 'kata_future'
require_relative 'id_generator'
require_relative 'saver_service'
require_relative 'starter'

class ExternalsFuture

  def saver
    @saver ||= SaverService.new
  end

  #def group
  #  @groups ||= GroupFuture.new(self)
  #end

  def kata
    @kata ||= KataFuture.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def starter
    @starter ||= Starter.new
  end

end
