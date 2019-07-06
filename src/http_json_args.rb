require_relative 'base58'
require_relative 'docker/image_name'
require_relative 'http_json/request_error'
require 'json'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(body)
    @args = JSON.parse(body)
    unless @args.is_a?(Hash)
      fail HttpJson::RequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    fail HttpJson::RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    case path
    when '/ready'  then ['ready?',[]]
    when '/sha'    then ['sha',[]]
    when '/colour' then ['colour',[image_name, id, stdout, stderr, status]]
    else
      raise HttpJson::RequestError, 'unknown path'
    end
  end

  private

  def image_name
    arg = @args[name = __method__.to_s]
    unless Docker::image_name?(arg)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def id
    arg = @args[name = __method__.to_s]
    unless well_formed_id?(arg)
      fail malformed(name)
    end
    arg
  end

  def well_formed_id?(arg)
    Base58.string?(arg) && arg.size === 6
  end

  # - - - - - - - - - - - - - - - -

  def stdout
    arg = @args[name = __method__.to_s]
    unless arg.is_a?(String)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def stderr
    arg = @args[name = __method__.to_s]
    unless arg.is_a?(String)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def status
    arg = @args[name = __method__.to_s]
    unless arg.is_a?(Integer)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def malformed(arg_name)
    HttpJson::RequestError.new("#{arg_name} is malformed")
  end

end
