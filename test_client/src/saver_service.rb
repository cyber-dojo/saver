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

  def exists_command(dirname)
    [EXISTS_COMMAND_NAME,dirname]
  end

  def create_command(dirname)
    [CREATE_COMMAND_NAME,dirname]
  end

  def write_command(filename,content)
    [WRITE_COMMAND_NAME,filename,content]
  end

  def append_command(filename,content)
    [APPEND_COMMAND_NAME,filename,content]
  end

  def read_command(filename)
    [READ_COMMAND_NAME,filename]
  end

  # - - - - - - - - - - - -
  # primitives

  def assert(command)
    @http.post(__method__, { command:command })
  end

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

  def exists?(dirname)
    @http.get(__method__, { key:dirname })
  end

  def create(dirname)
    @http.post(__method__, { key:dirname })
  end

  def write(filename, content)
    @http.post(__method__, { key:filename, value:content })
  end

  def append(filename, content)
    @http.post(__method__, { key:filename, value:content })
  end

  def read(filename)
    @http.get(__method__, { key:filename })
  end

  private

  EXISTS_COMMAND_NAME = 'exists?'
  CREATE_COMMAND_NAME = 'create'
  WRITE_COMMAND_NAME  = 'write'
  APPEND_COMMAND_NAME = 'append'
  READ_COMMAND_NAME   = 'read'

end
