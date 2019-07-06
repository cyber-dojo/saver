require_relative 'test_base'
require_relative '../src/http_json/response_unpacker'
require 'ostruct'

class ResponseUnpackerTest < TestBase

  def self.hex_prefix
    'D07'
  end

  # - - - - - - - - - - - - - - - - -

  class StubRequester
    def initialize(response)
      @response = response
    end
    def get(*args)
      OpenStruct.new(body:@response)
    end
  end

  test '4F5',
  %w( response is not a JSON hash raises ) do
    stub = StubRequester.new('[]')
    unpacker = HttpJson::ResponseUnpacker.new(stub)
    error = assert_raises(RuntimeError) { unpacker.get('goodbye', {id:42}) }
    assert_equal 'JSON is not a Hash', error.message
  end

  test '4F6',
  %w( response with no key matching the path raises ) do
    stub = StubRequester.new('{"abc":42}')
    unpacker = HttpJson::ResponseUnpacker.new(stub)
    error = assert_raises(RuntimeError) { unpacker.get('hello', {id:42}) }
    assert_equal "key for 'hello' is missing", error.message
  end

end
