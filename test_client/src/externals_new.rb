require_relative 'group_new'
require_relative 'group_id_generator'
require_relative 'kata_new'
require_relative 'kata_id_generator'
require_relative 'saver_service'
require_relative 'starter'

class ExternalsNew

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= GroupNew.new(self)
  end

  def group_id_generator
    @group_id_generator ||= GroupIdGenerator.new(self)
  end

  def kata
    @kata ||= KataNew.new(self)
  end

  def kata_id_generator
    @kata_id_generator ||= KataIdGenerator.new(self)
  end

  def starter
    @starter ||= Starter.new
  end

end
