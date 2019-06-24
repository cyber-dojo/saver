require_relative '../src/http'

class ExternalLanguages

  def names
    http.get
  end

  def manifests
    http.get
  end

  def manifest(name)
    http.get(name)
  end

  private

  def http
    Http.new(self, 'languages', 4524)
  end

end
