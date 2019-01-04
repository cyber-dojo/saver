require_relative 'test_base'

class ServicePortedTest < TestBase

  def self.hex_prefix
    '9C8'
  end

  # - - - - - - - - - - - - - - - - -

  test '1E0',
  %w( 200 example ) do
    assert ported.ported?('33EBEA')
    refute ported.ported?('112233')
  end

  # - - - - - - - - - - - - - - - - -

  test '1E1',
  %w( 400 example ) do
    error = assert_raises(ServiceError) { ported.four_hundred }
    json = JSON.parse!(error.message)
    assert_equal 'PortedService', json['class']
  end

end
