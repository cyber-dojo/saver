require_relative 'external/disk'
require_relative 'external/random'
require_relative 'external/shell'
require_relative 'external/time'
require_relative 'external/custom_start_points'
require_relative 'external/exercises_start_points'
require_relative 'external/languages_start_points'
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

  def shell
    @shell ||= External::Shell.new
  end

  # - - - - - - - - - - - -

  def custom_start_points
    @custom_start_points ||= External::CustomStartPoints.new
  end

  def exercises_start_points
    @exercises_start_points ||= External::ExercisesStartPoints.new
  end

  def languages_start_points
    @languages_start_points ||= External::LanguagesStartPoints.new
  end

end
