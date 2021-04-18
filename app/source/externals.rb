# frozen_string_literal: true
require_relative 'prober'
require_relative 'saver'

class Externals

  def prober
    @prober ||= Prober.new(self)
  end

  def saver
    @saver ||= Saver.new
  end

end
