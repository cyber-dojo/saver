require_relative 'test_base'
require_relative '../src/http_json_args'
require_relative '../src/http_json/request_error'

class HttpJsonArgsTest < TestBase

  def self.hex_prefix
    '0A1'
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
  # key

  # TODO: key is missing

  test 'B42',
  'get() raises when key is not String' do
    args = HttpJsonArgs.new('{"key":42}')
    error = assert_raises { args.get('/create', externals) }
    assert_equal 'malformed:key:!String:', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # value

  # TODO: value is missing

  test 'B43',
  'get() raises when value is not String' do
    args = HttpJsonArgs.new('{"key":"a/b/c","value":42}')
    error = assert_raises { args.get('/write', externals) }
    assert_equal 'malformed:value:!String:', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # commands

  # TODO: commands is missing
  # TODO: commands is malformed

end
