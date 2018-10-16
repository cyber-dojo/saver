require_relative 'test_base'

class IdValidatorTest < TestBase

  def self.hex_prefix
    '48D'
  end

  def id_validator
    externals.id_validator
  end

  # - - - - - - - - - - - - - - - - -

  test '1D4',
  'valid?(id) is false if group practice-session for id exists' do
    explicit_id = 'B79892'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = group_create(manifest)
    refute id_validator.valid?(id)
  end

end