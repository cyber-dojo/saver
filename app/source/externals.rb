# frozen_string_literal: true
require_relative 'external/prober'
require_relative 'external/random'
require_relative 'external/time'
require_relative 'saver'

class Externals

  def prober
    @prober ||= External::Prober.new(self)
  end

  def random
    @random ||= External::Random.new(self)
  end

  def saver
    @saver ||= Saver.new
  end

  def time
    @time ||= External::Time.new(self)
  end

end
