require_relative 'test_base'
require_relative '../src/base58'

class GroupIdGeneratorTest < TestBase

  def self.hex_prefix
    'CE2'
  end

  # - - - - - - - - - - - - - - - - -

  test '1D4',
  '[new] generated ids are Base58 ids that do not exist as groups' do
    42.times do
      id = group_id_generator.id
      assert id.is_a?(String)
      assert_equal 6, id.length
      assert Base58.string?(id)
      refute group.exists?(id)
    end
  end

end
