# frozen_string_literal: true
require_relative 'test_base'
require_source 'http_json_args'
require_source 'http_json/request_error'

class HttpJsonArgsTest < TestBase

  def self.id58_prefix
    '0A1'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9AD', %w(
    allow empty body in parameterless http requests;
    this is important for curl based requests,
    especially kubernetes liveness/readyness probes
  ) do
    args = HttpJsonArgs.new('')
    assert_equal [ prober, 'alive?', {} ], args.get('/alive', externals)
    assert_equal [ prober, 'ready?', {} ], args.get('/ready', externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F18', 'get: [saver] path and body ok' do
    args = HttpJsonArgs.new('{}')
    assert_equal [ prober, 'sha'   , {} ], args.get('/sha'  , externals)
    assert_equal [ prober, 'alive?', {} ], args.get('/alive', externals)
    assert_equal [ prober, 'ready?', {} ], args.get('/ready', externals)

    dirname = 'F18'
    filename = dirname + '/' + 'readme.txt'
    content = 'hello world'

    command = dir_make_command(dirname)
    args = HttpJsonArgs.new({"command":command}.to_json)
    expected = [ disk,'run',{ command: command} ]
    assert_equal expected, args.get('/run', externals)

    commands = [
        dir_make_command(dirname),
        file_create_command(filename, content)
    ]
    args = HttpJsonArgs.new({"commands":commands}.to_json)
    expected = [ disk,'run_all',{ commands: commands } ]
    assert_equal expected, args.get('/run_all', externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # c'tor
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A04',
  'ctor raises when its string arg is not JSON' do
    expected = 'body is not JSON'
    info = 'abc is not a valid top-level JSON element'
    error = assert_raises { HttpJsonArgs.new('abc') }
    assert_equal expected, error.message, info
    info = 'nil is null in JSON'
    error = assert_raises { HttpJsonArgs.new('{"x":nil}') }
    assert_equal expected, error.message, info
    info = 'keys have to be strings in JSON'
    error = assert_raises { HttpJsonArgs.new('{42:"answer"}') }
    assert_equal expected, error.message, info
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A05',
  'ctor raises when its string arg is not JSON Hash' do
    expected = 'body is not JSON Hash'
    error = assert_raises { HttpJsonArgs.new('[]') }
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # get

  test 'A06',
  'get raises when path is unknown' do
    args = HttpJsonArgs.new('{}')
    error = assert_raises { args.get('/nope', externals) }
    assert_equal 'unknown path', error.message
  end

end
