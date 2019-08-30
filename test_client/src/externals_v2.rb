require_relative 'group_v2'
require_relative 'kata_v2'
require_relative 'id_generator'
require_relative 'saver_service'
require_relative 'starter'

# Group/Kata manifests now have an explicit version.

class Externals_v2

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= Group_v2.new(self)
  end

  def kata
    @kata ||= Kata_v2.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def starter
    @starter ||= Starter.new
  end

end
