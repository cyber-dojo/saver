require_relative 'http'

class ExternalExercises

  def initialize
    @http = Http.new(self, 'exercises', 4525)
  end

  def manifest(name)
    @http.get(name)
  end

end
