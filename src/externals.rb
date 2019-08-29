# frozen_string_literal: true

require_relative 'saver'
require_relative 'bridge/group'
require_relative 'bridge/kata'
require_relative 'bridge/id_generator'

class Externals

  def saver
    @saver ||= Saver.new
  end

  def group
    @group ||= Group.new(self)
  end

  def kata
    @kata ||= Kata.new(self)
  end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

end
