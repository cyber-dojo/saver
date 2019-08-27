require_relative 'saver'
require 'net/http'

class Externals

  def saver
    @saver ||= Saver.new
  end

  def http
    @http ||= Net::HTTP
  end

end
