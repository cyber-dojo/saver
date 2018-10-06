require_relative 'test_base'

class ExternalIdValidatorTest < TestBase

  def self.hex_prefix
    'C72E3'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -
  # valid?(id)
  # - - - - - - - - - - - - - - - - - - - - - - -

  test '921',
  'false when initial 6-chars already used for existing id' do
    id = '82875424E7'
    stub_create(id)
    partial_id = id[0..6]
    refute_valid(partial_id + '0000')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '922',
  'false if id contains ell (lowercase or uppercase)' do
    ell = 'L'
    refute_valid('2466FD900' + ell.upcase)
    refute_valid('2466FD900' + ell.downcase)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '923',
  'true when initial 6-chars not yet used for existing id' do
    id = 'D9A3DC94C6'
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
