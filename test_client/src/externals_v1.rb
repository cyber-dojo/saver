require_relative 'group_v1'
require_relative 'kata_v1'
require_relative 'id_generator'
require_relative 'saver_service'
require_relative 'starter'

# Kata/Group methods are now multi-line methods
# hoisted out of the Saver service but with identical
# behaviour to v0.

class Externals_v1

  def saver
    @saver ||= SaverService.new
  end

  def group
    @groups ||= Group_v1.new(self)
  end

  def kata
    @kata ||= Kata_v1.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def starter
    @starter ||= Starter.new
  end

end
