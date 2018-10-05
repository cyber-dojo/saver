require_relative 'test_base'
require_relative 'id_generator_stub'

class IdGeneratorStubTest < TestBase

  def self.hex_prefix
    '871F9'
  end

  # - - - - - - - - - - - - - - - - -

  test '554',
  'ids can be stubbed' do
    stubber = IdGeneratorStub.new
    stub_1 = '668AFE90B0'
    stubber.stub(stub_1)
    id = stubber.generate
    assert_equal stub_1, id
  end

  # - - - - - - - - - - - - - - - - -

  test '555',
  'raises when out of stubs' do
    stubber = IdGeneratorStub.new
    error = assert_raises(RuntimeError) {
      stubber.generate
    }
    assert_equal 'IdGeneratorStub - @stubbed is empty', error.message
  end

end