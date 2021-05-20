require_relative 'external/random'
require_relative 'external/time'
require_relative 'external/disk'
require_relative 'model'
require_relative 'prober'

class Externals

  def disk
    @disk ||= External::Disk.new('cyber-dojo')
  end

  def model
    @model ||= Model.new(self)
  end

  def prober
    @prober ||= Prober.new
  end

  def random
    @random ||= External::Random.new
  end

  def time
    @time ||= External::Time.new
  end

end
