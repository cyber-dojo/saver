require_relative '../src/http_helper'

class ExternalMapper

  def initialize
    @http = HttpHelper.new(self, 'mapper', 4547)
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
