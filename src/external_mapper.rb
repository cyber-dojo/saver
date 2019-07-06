require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class ExternalMapper

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals, 'mapper', 4547)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def ready?
    @http.get(__method__, {})
  end

  def mapped?(id6)
    @http.get(__method__, { id6:id6 })
  end

  def four_hundred
    @http.get(__method__, {})
  end

end
