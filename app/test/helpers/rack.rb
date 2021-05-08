# frozen_string_literal: true
require_relative '../require_source'
require_source 'app'

module TestHelpersRack

  include Rack::Test::Methods

  def app
    @app ||= App.new(externals)
  end

  def get_json(path, data)
    get path, data, JSON_REQUEST_HEADERS
    last_response
  end

  def put_json(path, data)
    put path, data, JSON_REQUEST_HEADERS
    last_response
  end

  def post_json(path, data)
    post path, data, JSON_REQUEST_HEADERS
    last_response
  end

  JSON_REQUEST_HEADERS = {
    'CONTENT_TYPE' => 'application/json', # sent
    'HTTP_ACCEPT' => 'application/json'   # want
  }

end
