require_relative 'http'

class ExternalMapper

  def initialize
    @http = Http.new(self, 'mapper', 4547)
  end

  def ready?
    http.get
  end

  def mapped?(id6)
    http.get(id6)
  end

  def four_hundred
    http.get
  end

  private

  attr_reader :http

end
