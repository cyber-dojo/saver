require_relative 'http_json/requester'
require_relative 'http_json/responder'
require 'net/http'

class SaverService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize
    requester = HttpJson::Requester.new(Net::HTTP, 'saver', 4537)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
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

  def dir_exists_command(dirname)
    [DIR_EXISTS_COMMAND_NAME,dirname]
  end

  def dir_make_command(dirname)
    [DIR_MAKE_COMMAND_NAME,dirname]
  end

  def file_create_command(filename,content)
    [FILE_CREATE_COMMAND_NAME,filename,content]
  end

  def file_append_command(filename,content)
    [FILE_APPEND_COMMAND_NAME,filename,content]
  end

  def file_read_command(filename)
    [FILE_READ_COMMAND_NAME,filename]
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

  def assert_all(commands)
    @http.post(__method__, { commands:commands })
  end

  def run_all(commands)
    @http.post(__method__, { commands:commands })
  end

  def run_until_true(commands)
    @http.post(__method__, { commands:commands })
  end

  def run_until_false(commands)
    @http.post(__method__, { commands:commands })
  end

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

  def batch(commands)
    @http.post(__method__, { commands:commands })
  end

  private

  DIR_EXISTS_COMMAND_NAME = 'dir_exists?'
  DIR_MAKE_COMMAND_NAME   = 'dir_make'

  FILE_CREATE_COMMAND_NAME = 'file_create'
  FILE_APPEND_COMMAND_NAME = 'file_append'
  FILE_READ_COMMAND_NAME   = 'file_read'

end
