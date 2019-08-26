require_relative 'test_base'
require_relative '../src/base58'

class KataIdGeneratorTest < TestBase

  def self.hex_prefix
    '891'
  end

  def id_generator
    externals.kata_id_generator
  end

  # - - - - - - - - - - - - - - - - -

  test '1D4',
  'generated ids are Base58 ids that do not exist as katas' do
    42.times do
      id = id_generator.id
      assert id.is_a?(String)
      assert_equal 6, id.length
      assert Base58.string?(id)
      refute katas.kata_exists?(id)
    end
  end

end
