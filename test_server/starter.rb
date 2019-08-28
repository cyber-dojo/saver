require_relative 'external_exercises'
require_relative 'external_languages'

class Starter

  def manifest
    lm = languages.manifest(default_display_name)
    em = exercises.manifest(default_exercise_name)
    lm['visible_files'].merge!(em['visible_files'])
    lm['created'] = creation_time
    lm
  end

  def creation_time
    [2016,12,2, 6,13,23,6546]
  end

  private

  def default_display_name
    'C (gcc), assert'
  end

  def default_exercise_name
    'Fizz Buzz'
  end

  # - - - - - - - - - - - - - - -

  def exercises
    ExternalExercises.new
  end

  def languages
    ExternalLanguages.new
  end

end
