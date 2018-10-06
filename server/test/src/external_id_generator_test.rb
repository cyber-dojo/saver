require_relative 'test_base'

class ExternalIdGeneratorTest < TestBase

  def self.hex_prefix
    '9E748'
  end

  def id_generator
    @id_generator ||= ExternalIdGenerator.new(self)
  end

  def id_validator
    @id_validator ||= ExternalIdValidator.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

  # - - - - - - - - - - - - - - - -

  test '926',
  'generates Base58 ids of length 6' do
    id = id_generator.generate
    assert Base58.string?(id), "Base58.string?('#{id}')"
    assert_equal 6, id.size
  end

  # - - - - - - - - - - - - - - - -

  test '927',
  'skips Base58 ids that the validator rejects' do
    @id_validator = IdValidatorStub.new(3)
    id = id_generator.generate
    assert_equal 3, @id_validator.count
  end

  # - - - - - - - - - - - - - - - -

  class IdValidatorStub
    def initialize(n)
      @n = n
      @count = 0
    end

    attr_reader :count

    def valid?(id)
      @count += 1
      @count >= @n
    end
  end

end
