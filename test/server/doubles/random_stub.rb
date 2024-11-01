class RandomStub

  def initialize(letters)
    alphabet = IdGenerator::ALPHABET
    @indexes = letters.each_char.map{ |ch| alphabet.index(ch) }
    @n = 0
  end

  def sample(_size)
    index = @indexes[@n]
    @n += 1
    index
  end

end
