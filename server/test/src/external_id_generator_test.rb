require_relative 'test_base'

class ExternalIdGeneratorTest < TestBase

  def self.hex_prefix
    '9E748'
  end

  # - - - - - - - - - - - - - - - -

  test '926',
  'generates Base58 ids' do
    id = externals.id_generator.generate
    assert Base58.string?(id), "Base58.string?(#{id})"
    assert_equal 10, id.size
  end

end
