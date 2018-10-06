require_relative 'base58'

# Rack calls grouper.create() in threads so in
# theory you could get a race condition with both
# threads attempting a create with the same id.
# Assuming base58 id generation is reasonably well
# behaved (random) this is extremely unlikely.

class ExternalIdGenerator

  def initialize(externals)
    @externals = externals
  end

  def generate
    loop do
      id = Base58.string(6)
      if valid?(id)
        return id
      end
    end
  end

  private

  def valid?(id)
    id_validator.valid?(id)
  end

  def id_validator
    @externals.id_validator
  end

end
