require_relative '../src/http_helper'

class ExternalPorted

  def initialize
    @http = HttpHelper.new(self, 'ported', 4547)
  end

  def ported?(id6)
    http.get(id6)
  end

  def four_hundred
    http.get
  end

  private

  attr_reader :http

end
