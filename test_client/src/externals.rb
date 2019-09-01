require_relative 'group'
require_relative 'kata'
require_relative 'id_generator'
require_relative 'saver_service'
require_relative 'starter'

class Externals

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= Group.new(self)
  end

  def kata
    @kata ||= Kata.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def starter
    @starter ||= Starter.new
  end

end
