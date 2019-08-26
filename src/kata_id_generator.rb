require_relative 'base58'

class KataIdGenerator

  def initialize(externals)
    @externals = externals
  end

  def id
    loop do
      id = Base58.string(6)
      unless kata.exists?(id)
        return id
      end
    end
  end

  private

  def kata
    @externals.kata
  end

end
