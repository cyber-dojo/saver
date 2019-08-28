require_relative '../src/bridge/request_packer'
require_relative '../src/bridge/response_unpacker'
require 'net/http'

class ExternalExercises

  def initialize
    requester = HttpJson::RequestPacker.new(Net::HTTP, 'exercises', 4525)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
