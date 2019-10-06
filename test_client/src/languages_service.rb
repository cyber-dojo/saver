require_relative 'http_json/requester'
require_relative 'http_json/responder'
require_relative 'http_service_exception'
require 'net/http'

class LanguagesService

  def initialize
    requester = HttpJson::Requester.new(Net::HTTP, 'languages', 4524)
    @http = HttpJson::Responder.new(requester, HttpServiceException)
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
