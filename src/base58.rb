require 'securerandom'

# Similar to https://en.wikipedia.org/wiki/Base58
# o) includes the digits zero and one
#    (to be backwards compatible as hex)
# o) excludes the letters IO
#    (India,Oscar) both lowercase and uppercase
#
# Within a single server it is easy to guarantee
# there are no ID clashes. However, the larger
# the alphabet the less you have to worry about
# ID clashes when copying sessions from one
# server to another.
#
# 58^6 == 38,068,692,544 == 38 billion

class Base58

  def self.string(size)
    size.times.map{ letter }.join
  end

  def self.string?(s)
    s.is_a?(String) &&
      s.chars.all?{ |char| letter?(char) }
  end

  def self.alphabet
    ALPHABET
  end

  private

  def self.letter
    alphabet[index]
  end

  def self.index
    SecureRandom.random_number(alphabet.size)
  end

  def self.letter?(char)
    alphabet.include?(char)
  end

  ALPHABET = %w{
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h   j k l m n   p q r s t u v w x y z
  }.join

end