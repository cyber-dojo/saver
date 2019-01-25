require_relative 'test_base'
require_relative '../src/http'

class ServiceStarterTest < TestBase

  def self.hex_prefix
    '84E'
  end

  # - - - - - - - - - - - - - - - - -

  test '1E0',
  %w( 200 example ) do
    language_manifest('C (gcc), assert', 'Fizz_Buzz')
  end

  test '1E1',
  %w( 400 example ) do
    error = assert_raises(ServiceError) { four_hundred }
    json = JSON.parse!(error.message)
    assert_equal 'ClientError', json['class']
  end

  private

  def language_manifest(display_name, exercise_name)
    http.get(display_name, exercise_name)
  end

  def four_hundred
    http.get
  end

  def http
    Http.new(self, 'starter', 4527)
  end

end
