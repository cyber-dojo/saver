require_relative 'test_base'

class ExternalIdValidatorTest < TestBase

  def self.hex_prefix
    'C72E3'
  end

  def hex_setup
    @real_id_generator = externals.id_generator
    @stub_id_generator = IdGeneratorStub.new
    externals.id_generator = @stub_id_generator
  end

  def hex_teardown
    externals.id_generator = @real_id_generator
  end

  attr_reader :stub_id_generator

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '920',
  'false when id already used' do
    id = '82875424E7'
    stub_create(id)
    refute id_validator.valid?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '921',
  'false when initial 6-chars already used for existing id' do
    id = '82875424E7'
    stub_create(id)
    partial_id = id[0..6]
    refute id_validator.valid?(partial_id + '0000')
  end

  private

  def id_validator
    @externals.id_validator
  end

end
