require_relative 'http'

class StarterService

  def initialize
    @http = Http.new(self, 'starter', 4527)
  end

  def manifest
    json = language_manifest(display_name, exercise_name)
    manifest = json['manifest']
    manifest['created'] = creation_time
    manifest['exercise'] = exercise_name
    manifest['visible_files']['readme.txt'] = json['exercise']
    manifest
  end

  def creation_time
    [2016,12,2, 6,13,23,7654]
  end

  private

  attr_reader :http

  def language_manifest(display_name, exercise_name)
    http.get(display_name, exercise_name)
  end

  def display_name
    'C (gcc), assert'
  end

  def exercise_name
    'Fizz_Buzz'
  end

end
