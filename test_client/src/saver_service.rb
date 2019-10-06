require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'saver_exception'
require 'net/http'

class SaverService

  def initialize
    requester = HttpJson::RequestPacker.new(Net::HTTP, 'saver', 4537)
    @http = HttpJson::ResponseUnpacker.new(requester, SaverException)
  end

  # - - - - - - - - - - - -

  def sha
    @http.get(__method__, {})
  end

  def ready?
    @http.get(__method__, {})
  end

  def alive?
    @http.get(__method__, {})
  end

  def create(key)
    @http.post(__method__, { key:key })
  end

  def exists?(key)
    @http.get(__method__, { key:key })
  end

  def write(key, value)
    @http.post(__method__, { key:key, value:value })
  end

  def append(key, value)
    @http.post(__method__, { key:key, value:value })
  end

  def read(key)
    @http.get(__method__, { key:key })
  end

  def batch(commands)
    @http.post(__method__, { commands:commands })
  end

end
