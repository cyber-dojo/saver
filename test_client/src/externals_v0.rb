require_relative 'group_v0'
require_relative 'kata_v0'
require_relative 'id_generator'
require_relative 'saver_service'
require_relative 'starter'

# Kata/Group methods are all one-line calls
# to explicit Saver-service methods. There is
# no id-generator as this happens inside Saver.

class Externals_v0

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= Group_v0.new(self)
  end

  def kata
    @kata ||= Kata_v0.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def starter
    @starter ||= Starter.new
  end

end
