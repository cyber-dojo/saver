# frozen_string_literal: true
require_relative 'id_pather'

class IdGenerator

  SAVER_OFFLINE_ID = '999999'

  ALPHABET = %w{
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h   j k l m n   p q r s t u v w x y z
  }.join.freeze

  def self.id?(s)
    s.is_a?(String) &&
      s.length === SIZE &&
        s.chars.all?{ |ch| ALPHABET.include?(ch) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def initialize(externals)
    @externals = externals
  end

  def group_id
    generate_id(:group_id_path, :kata_id_path)
  end

  def kata_id
    generate_id(:kata_id_path, :group_id_path)
  end

  private

  SIZE = 6

  include IdPather

  def generate_id(pather, not_pather)
    42.times.find do
      id = SIZE.times.map{ ALPHABET[random_index] }.join
      if reserved?(id)
        next
      end
      dir_exists = saver.dir_exists_command(method(not_pather).call(id))
      if saver.run(command:dir_exists)
        next
      end
      dir_make = saver.dir_make_command(method(pather).call(id))
      if saver.run(command:dir_make)
        break id
      end
    end
  end

  def reserved?(id)
    id === SAVER_OFFLINE_ID
  end

  def random_index
    random.sample(ALPHABET.size)
  end

  def random
    @externals.random
  end

  def saver
    @externals.saver
  end

end

# Similar to https://en.wikipedia.org/wiki/Base58
# o) includes the digits zero and one
#    (to be backwards compatible as hex)
# o) excludes the letters IO
#    (India,Oscar) both lowercase and uppercase
#
# Within a single server it is easy to guarantee
# there are no ID clashes. However, the larger
# the alphabet the less you have to worry about
# ID clashes when merging server sessions.
#
# 58^6 == 38,068,692,544 == 38 billion
