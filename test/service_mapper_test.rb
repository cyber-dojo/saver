require_relative 'test_base'

class ServiceMapperTest < TestBase

  def self.hex_prefix
    '9C8'
  end

  # - - - - - - - - - - - - - - - - -

  test '1E0',
  %w( 200 example ) do
    assert mapper.mapped?('33EBEA')
    refute mapper.mapped?('112233')
  end

  # - - - - - - - - - - - - - - - - -

  test '1E1',
  %w( 400 example ) do
    error = assert_raises(ServiceError) { mapper.four_hundred }
    json = JSON.parse!(error.message)
    assert_equal 'MapperService', json['class']
  end

end
