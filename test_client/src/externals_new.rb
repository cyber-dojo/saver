require_relative 'group_new'
require_relative 'kata_new'
require_relative 'id_generator'
require_relative 'saver_service'
require_relative 'starter'

class ExternalsNew

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= GroupNew.new(self)
  end

  def kata
    @kata ||= KataNew.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def starter
    @starter ||= Starter.new
  end

end
