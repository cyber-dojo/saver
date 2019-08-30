require_relative 'exercises_service'
require_relative 'languages_service'

class Starter

  def initialize
    @exercises = ExercisesService.new
    @languages = LanguagesService.new
  end

  def manifest
    # (mimics what web does)
    lm = @languages.manifest(default_display_name)
    em = @exercises.manifest(default_exercise_name)
    lm['visible_files'].merge!(em['visible_files'])
    lm['created'] = creation_time
    lm
  end

  def creation_time
    [ 2019,12,2, 6,13,23,6546 ]
  end

  private

  def default_display_name
    'C (gcc), assert'
  end

  def default_exercise_name
    'Fizz Buzz'
  end

end
