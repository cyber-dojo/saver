require_relative '../src/http_json/request_packer'
require_relative '../src/http_json/response_unpacker'

class ExternalLanguages

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals, 'languages', 4524)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
