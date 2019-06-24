require_relative 'http'

class ExternalLanguages

  def manifest(name)
    http.get(name)
  end

  private

  def http
    Http.new(self, 'languages', 4524)
  end

end
