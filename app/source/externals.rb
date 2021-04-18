# frozen_string_literal: true
require_relative 'disk'
require_relative 'external/prober'
require_relative 'external/random'
require_relative 'external/time'

class Externals

  def disk
    @disk ||= Disk.new
  end

  def prober
    @prober ||= External::Prober.new(self)
  end

  def random
    @random ||= External::Random.new(self)
  end

  def time
    @time ||= External::Time.new(self)
  end

end
