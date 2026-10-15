require 'rack/test'
require_relative 'test_base'
require_source 'app'

class ProberRoutesTest < TestBase

  include Rack::Test::Methods

  test 'Rq7xA1',
  %w( GET /alive? returns true as JSON ) do
    assert_equal({ 'alive?' => true }, get_json('/alive?'))
  end

  test 'Rq7xA2',
  %w( GET /ready? returns true as JSON ) do
    assert_equal({ 'ready?' => true }, get_json('/ready?'))
  end

  test 'Rq7xA3',
  %w( GET /sha returns the sha of the saver image's git commit as JSON ) do
    assert_equal({ 'sha' => saver.sha }, get_json('/sha'))
  end

  private

  def app
    App.new(externals)
  end

  def get_json(path)
    get(path, {}, { 'HTTP_ACCEPT' => 'application/json' })
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.headers['Content-Type']
    JSON.parse(last_response.body)
  end

end
