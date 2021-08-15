require_relative 'external/custom_start_points'
require_relative 'external/exercises_start_points'
require_relative 'external/languages_start_points'
require_relative 'external/http'
require_relative 'external/saver'

class Externals

  def custom_start_points
    @custom_start_points ||= External::CustomStartPoints.new
  end

  def exercises_start_points
    @exercises_start_points ||= External::ExercisesStartPoints.new
  end

  def languages_start_points
    @languages_start_points ||= External::LanguagesStartPoints.new
  end

  def saver
    @saver ||= External::Saver.new(http)
  end

  def http
    @http ||= External::Http.new
  end

end
