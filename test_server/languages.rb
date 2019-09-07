require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require 'net/http'

class Languages

  def initialize
    requester = HttpJson::RequestPacker.new(Net::HTTP, 'languages', 4524)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
