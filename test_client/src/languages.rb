require_relative 'http'

class Languages

  def initialize
    @http = Http.new(self, 'languages', 4524)
  end

  def manifest(name)
    @http.get(name)
  end

end
