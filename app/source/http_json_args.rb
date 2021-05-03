# frozen_string_literal: true
require_relative 'lib/json_adapter'
require_relative 'prober'
require_relative 'request_error'

class HttpJsonArgs

  def initialize(body)
    if body === ''
      body = '{}'
    end
    @args = json_parse(body)
    unless @args.is_a?(Hash)
      fail RequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
  #rescue Oj::ParseError
    fail RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path, externals)
    prober = externals.prober
    disk = externals.disk
    args = case path
    when '/sha'     then [prober,'sha']
    when '/ready'   then [prober,'ready?']
    when '/alive'   then [prober,'alive?']

    when '/assert'  then [disk,'assert',command]
    when '/run'     then [disk,'run'   ,command]

    when '/assert_all'      then [disk,'assert_all'     ,commands]
    when '/run_all'         then [disk,'run_all'        ,commands]
    when '/run_until_true'  then [disk,'run_until_true' ,commands]
    when '/run_until_false' then [disk,'run_until_false',commands]

    else
      fail RequestError, 'unknown path'
    end

    target = args.shift
    name = args.shift
    if args != []
      args = args[0]
    end
    args = Hash[args.map{ |key,value| [key.to_sym, value] }]
    [target, name, args]
  end

  private

  include JsonAdapter

  attr_reader :args

  def command
    { command: args['command'] }
  end

  def commands
    { commands: args['commands'] }
  end

end
