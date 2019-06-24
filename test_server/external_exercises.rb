require_relative '../src/http'

class ExternalExercises

  def manifest(name)
    http.get(name)
  end

  private

  def http
    Http.new(self, 'exercises', 4525)
  end

end
