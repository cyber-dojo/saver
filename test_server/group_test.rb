require_relative 'test_base'

class GroupTest < TestBase

  def self.hex_prefix
    '974'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'exists?(id) is false before creation, true after creation' do
    id = '50C8C6'
    refute group.exists?(id)
    id_generator_stub(id)
    gid = group.create(starter.manifest)
    assert_equal id, gid
    assert group.exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id=create(), manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'create() generates id' do
    manifest = starter.manifest
    refute manifest.key?('id')
    id = group.create(manifest)
    assert manifest.key?('id')
    assert_equal id, manifest['id']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '420',
  'manifest(id) raises when id does not exist' do
    assert_raises(ArgumentError) { group.manifest('B4AB37') }
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'create() manifest() round-trip' do
    id = group.create(starter.manifest)
    expected = starter.manifest
    expected['id'] = id
    assert_equal expected, group.manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # join(), joined()
  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D0',
  'join(id) raises when id does not exist' do
    assert_raises(ArgumentError) { group.join('B4AB37', indexes) }
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D3', %w(
  join(id) a non-full group with valid id succeeds
  and returns the kata's id
  and the manifest of the joined participant contains
  the group id and the avatar index ) do
    gid = group.create(starter.manifest)
    shuffled = indexes
    kid = group.join(gid, shuffled)
    assert kata.exists?(kid)
    manifest = kata.manifest(kid)
    assert_equal gid, manifest['group_id']
    assert_equal shuffled[0], manifest['group_index']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D4', %w(
  join() with a valid id succeeds 64 times
  then its full and it fails with nil
  ) do
    gid = group.create(starter.manifest)
    kids = []
    avatar_indexes = []
    64.times do
      kid = group.join(gid, indexes)
      refute_nil kid
      assert kid.is_a?(String), "kid is a #{kid.class.name}!"
      assert_equal 6, kid.size
      assert kata.exists?(kid), "!kata.exists?(#{kid})"
      kids << kid
      assert_equal kids.sort, group.joined(gid).sort

      index = kata.manifest(kid)['group_index']
      refute_nil index
      assert index.is_a?(Integer), "index is a #{index.class.name}"
      assert (0..63).include?(index), "!(0..63).include?(#{index})"
      refute avatar_indexes.include?(index), "avatar_indexes.include?(#{index})!"
      avatar_indexes << index
    end
    refute_equal (0..63).to_a, avatar_indexes
    assert_equal (0..63).to_a, avatar_indexes.sort
    assert_nil group.join(gid, indexes)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'joined(id) returns nil when the id does not exist' do
    assert_nil group.joined('B4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D5',
  'joined() information can be retrieved' do
    gid = group.create(starter.manifest)
    kids = group.joined(gid)
    expected = []
    assert_equal(expected, kids, 'someone has already joined!')
    (1..4).to_a.each do |n|
      kid = group.join(gid, indexes)
      expected << kid
      kids = group.joined(gid)
      assert kids.is_a?(Array), "kids is a #{kids.class.name}!"
      assert_equal n, kids.size, 'incorrect size!'
      assert_equal expected.sort, kids.sort, 'does not round-trip!'
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # events()
  #- - - - - - - - - - - - - - - - - - - - - -

  test 'A04', %w(
  events(id) returns null when the id does not exist ) do
      assert_nil group.events('B4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test 'A05', %w(
  events() is a BatchMethod for web's dashboard ) do
    gid = group.create(starter.manifest)
    kid1 = group.join(gid, indexes)
    index1 = kata.manifest(kid1)['group_index']
    kid2 = group.join(gid, indexes)
    index2 = kata.manifest(kid2)['group_index']
    kata.ran_tests(*make_ran_test_args(kid1, 1, edited_files))

    expected = {
      kid1 => {
        'index' => index1,
        'events' => [event0, { 'colour' => 'red', 'time' => time_now, 'duration' => duration }]
      },
      kid2 => {
        'index' => index2,
        'events' => [event0]
      }
    }
    actual = group.events(gid)
    assert_equal expected, actual
  end

  private

  def indexes
    (0..63).to_a.shuffle
  end

end
