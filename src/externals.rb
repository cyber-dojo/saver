# frozen_string_literal: true

require_relative 'saver'
require_relative 'bridge/group'
require_relative 'bridge/group_id_generator'
require_relative 'bridge/kata'
require_relative 'bridge/kata_id_generator'

class Externals

  def saver
    @saver ||= Saver.new
  end

  def group
    @group ||= Group.new(self)
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

end
