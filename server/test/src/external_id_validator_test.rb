require_relative 'test_base'

class ExternalIdValidatorTest < TestBase

  def self.hex_prefix
    'C72E3'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -
  # valid?(id)
  # - - - - - - - - - - - - - - - - - - - - - - -

  test '921',
  'false when group with id already exists' do
    id = '828754'
    stub_create(id)
    refute_valid(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '922',
  'false if id contains ell (lowercase or uppercase)' do
    ell = 'L'
    refute_valid('2466F' + ell.upcase)
    refute_valid('2466F' + ell.downcase)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '923',
  'true when group with id does not already exist' do
    id = 'D9A3DC'
    assert_valid(id)
  end

  private

  def assert_valid(id)
    assert id_validator.valid?(id)
  end

  def refute_valid(id)
    refute id_validator.valid?(id)
  end

  def id_validator
    externals.id_validator
  end

end
