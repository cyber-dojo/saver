require_relative 'http_json/requester'
require_relative 'http_json/responder'
require_relative 'saver_exception'
require 'net/http'

class SaverService

  def initialize
    requester = HttpJson::Requester.new(Net::HTTP, 'saver', 4537)
    @http = HttpJson::Responder.new(requester, SaverException)
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

  # - - - - - - - - - - - -

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

  # - - - - - - - - - - - -
  #assert(command)
  #run(command)
  #def batch_assert(commands)

  def batch_run(commands)
    @http.post(__method__, { commands:commands })
  end

  #batch_run_until_true
  #batch_run_until_false
end
