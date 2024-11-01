require_relative 'external/http'
require_relative 'external/saver'

class Externals

  def saver
    @saver ||= External::Saver.new(http)
  end

  def http
    @http ||= External::Http.new
  end

end
