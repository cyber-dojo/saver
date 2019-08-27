require_relative 'group'
require_relative 'group_id_generator'
require_relative 'kata'
require_relative 'kata_id_generator'
require_relative 'saver_service'
require_relative 'starter'

class Externals

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= Group.new(self)
  end

  def group_id_generator
    @group_id_generator ||= GroupIdGenerator.new(self)
  end

  def kata
    @kata ||= Kata.new(self)
  end

  def kata_id_generator
    @kata_id_generator ||= KataIdGenerator.new(self)
  end

  def starter
    @starter ||= Starter.new
  end

end