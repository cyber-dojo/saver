# frozen_string_literal: true

require_relative 'http_json/request_error'
require 'json'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(body)
    @args = JSON.parse!(body)
    unless @args.is_a?(Hash)
      fail HttpJson::RequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    fail HttpJson::RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    args = case path
    when '/sha'               then ['sha']
    when '/ready'             then ['ready?']
    when '/exists'            then ['exists?', key]
    when '/write'             then ['write', key, value]
    when '/append'            then ['append', key, value]
    when '/read'              then ['read', key]
    when '/batch_read'        then ['batch_read', keys]
    when '/batch_until_false' then ['batch_until_false', commands]
    when '/batch_until_true'  then ['batch_until_true',  commands]
    else
      fail HttpJson::RequestError, 'unknown path'
    end
    name = args.shift
    [name, args]
  end

  # - - - - - - - - - - - - - - - -

  attr_reader :args

  def key
    well_formed_string('key')
  end

  def value
    well_formed_string('value')
  end

  def keys
    well_formed_keys
  end

  def commands
    well_formed_commands
  end

  # - - - - - - - - - - - - - - -

  def well_formed_string(name)
    arg = @args[name]
    unless arg.is_a?(String)
      malformed(name, "!String (#{arg.class.name})")
    end
    arg
  end

  def well_formed_keys
    name = 'keys'
    args = @args[name]
    unless args.is_a?(Array)
      malformed(name, "!Array (#{args.class.name})")
    end
    args.each do |arg|
      unless arg.is_a?(String)
        malformed(name, "!String (#{arg.class.name})")
      end
    end
    args
  end

  def well_formed_commands
    name = 'commands'
    args = @args[name]
    # TODO
    args
  end

  # - - - - - - - - - - - - - - - -

  def malformed(arg_name, msg)
    raise HttpJson::RequestError.new("malformed:#{arg_name}:#{msg}:")
  end

end
