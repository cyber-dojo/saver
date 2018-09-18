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
    iid = nil
    loop do
      iid = Base58.string(10)
      break if valid?(iid)
    end
    iid
  end

  private

  def grouper
    @externals.grouper
  end

  def valid?(id)
    !grouper.id?(id) && !id.upcase.include?('L')
  end

end
