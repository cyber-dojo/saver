require_relative '../src/http_helper'

class ExternalStarter

  def manifest
    json = language_manifest(default_display_name, default_exercise_name)
    manifest = json['manifest']
    manifest['created'] = creation_time
    manifest['exercise'] = default_exercise_name
    manifest['visible_files']['readme.txt'] = json['exercise']
    manifest
  end

  def language_manifest(display_name, exercise_name)
    http.get(display_name, exercise_name)
  end

  def creation_time
    [2016,12,2, 6,13,23,6546]
  end

  private

  def default_display_name
    'C (gcc), assert'
  end

  def default_exercise_name
    'Fizz_Buzz'
  end

  # - - - - - - - - - - - - - - -

  def http
    HttpHelper.new(self, 'starter', 4527)
  end

end
