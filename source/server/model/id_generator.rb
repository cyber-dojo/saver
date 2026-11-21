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

  def initialize(externals)
    @externals = externals
  end

  def group_id
    generate_id(:group_id_path, :kata_id_path, :cluster_id_path)
  end

  def kata_id
    generate_id(:kata_id_path, :group_id_path, :cluster_id_path)
  end

  def cluster_id
    generate_id(:cluster_id_path, :group_id_path, :kata_id_path)
  end

  private

  SIZE = 6

  include IdPather

  # The first id, of up to 256 random tries, whose dir pather makes;
  # nil when every try fails.
  def generate_id(pather, *not_pathers)
    256.times do
      id = claim_id(pather, not_pathers)
      return id unless id.nil?
    end
    nil
  end

  # A random id, its dir made by pather; nil when the id is reserved,
  # is already one of not_pathers', or its dir cannot be made.
  def claim_id(pather, not_pathers)
    id = random_id
    id if claimed?(id, pather, not_pathers)
  end

  # A random id of SIZE characters from ALPHABET.
  def random_id
    SIZE.times.map{ ALPHABET[random_index] }.join
  end

  # True when id is not reserved, is not already one of not_pathers',
  # and pather makes its dir; checked in that order, each only when
  # the ones before pass.
  def claimed?(id, pather, not_pathers)
    !reserved?(id) && !clashes?(id, not_pathers) && made_dir?(pather, id)
  end

  # True when id is already one of not_pathers', so ids do not clash
  # across groups, katas and clusters.
  def clashes?(id, not_pathers)
    not_pathers.any? { |np| disk.run(disk.dir_exists_command(method(np).call(id))) }
  end

  # True when pather makes id's dir; false when making it fails.
  def made_dir?(pather, id)
    command = disk.dir_make_command(method(pather).call(id))
    begin
      disk.assert(command)
      true
    rescue
      false
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

  def disk
    @externals.disk
  end

end

# The id alphabet is similar to https://en.wikipedia.org/wiki/Base58
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
