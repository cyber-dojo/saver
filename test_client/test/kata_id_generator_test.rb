require_relative 'test_base'
require_relative '../src/base58'

class KataIdGeneratorTest < TestBase

  def self.hex_prefix
    '891'
  end

  # - - - - - - - - - - - - - - - - -

  test '1D4',
  '[new] generated ids are Base58 ids that do not exist as katas' do
    42.times do
      id = kata_id_generator.id
      assert id.is_a?(String)
      assert_equal 6, id.length
      assert Base58.string?(id)
      refute kata.exists?(id)
    end
  end

end
