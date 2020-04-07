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

  def exists_command(key)
    [EXISTS_COMMAND_NAME,key]
  end

  def create_command(key)
    [CREATE_COMMAND_NAME,key]
  end

  def write_command(key,value)
    [WRITE_COMMAND_NAME,key,value]
  end

  def append_command(key,value)
    [APPEND_COMMAND_NAME,key,value]
  end

  def read_command(key)
    [READ_COMMAND_NAME,key]
  end

  # - - - - - - - - - - - -
  # primitives

  #assert(command)

  def run(command)
    @http.post(__method__, { command:command })
  end

  # - - - - - - - - - - - -
  # batches

  #def batch_assert(commands)

  def batch_run(commands)
    @http.post(__method__, { commands:commands })
  end

  #batch_run_until_true
  #batch_run_until_false

  # - - - - - - - - - - - -
  # deprecated

  #exists?
  #create
  #write
  #append
  #read

  private

  EXISTS_COMMAND_NAME = 'exists?'
  CREATE_COMMAND_NAME = 'create'
  WRITE_COMMAND_NAME  = 'write'
  APPEND_COMMAND_NAME = 'append'
  READ_COMMAND_NAME   = 'read'

end
