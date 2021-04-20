# frozen_string_literal: true
require_relative 'external/disk'
require_relative 'external/prober'
require_relative 'external/random'
require_relative 'external/time'

class Externals

  def disk
    @disk ||= External::Disk.new
  end

  def prober
    @prober ||= External::Prober.new
  end

  def random
    @random ||= External::Random.new
  end

  def time
    @time ||= External::Time.new
  end

end
