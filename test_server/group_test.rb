require_relative 'test_base'

class GroupTest < TestBase

  def self.hex_prefix
    '974'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # group_exists?(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'group_exists? is false before creation, true after creation' do
    id = '50C8C6'
    refute group_exists?(id)
    stub_group_create(id)
    assert group_exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # group_create(manifest) group_manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42F', %w(
  group_create raises when id's dir cannot be created
  ) do
    id = group_create(starter.manifest)
    error = assert_raises(ArgumentError) {
      stub_group_create(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'group_create() generates id' do
    manifest = starter.manifest
    refute manifest.key?('id')
    id = group_create(manifest)
    assert manifest.key?('id')
    assert_equal id, manifest['id']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '420',
  'group_manifest() raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      group_manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'group_create() group_manifest() round-trip' do
    id = group_create(starter.manifest)
    expected = starter.manifest
    expected['id'] = id
    assert_equal expected, group_manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # group_join() / group_joined()
  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D0',
  'group_join raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      group_join(id, indexes)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D3', %w(
  group_join a non-full group with valid id succeeds
  and returns the kata's id
  and the manifest of the joined participant contains
  the group id and the avatar index ) do
    gid = group_create(starter.manifest)
    shuffled = indexes
    kid = group_join(gid, shuffled)
    assert kata_exists?(kid)
    manifest = kata_manifest(kid)
    assert_equal gid, manifest['group_id']
    assert_equal shuffled[0], manifest['group_index']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D4', %w(
  group_join with a valid id succeeds 64 times
  then its full and it fails with nil
  ) do
    gid = group_create(starter.manifest)
    kids = []
    avatar_indexes = []
    64.times do
      kid = group_join(gid, indexes)
      refute_nil kid
      assert kid.is_a?(String), "kid is a #{kid.class.name}!"
      assert_equal 6, kid.size
      assert kata_exists?(kid), "!kata_exists?(#{kid})"
      kids << kid
      assert_equal kids.sort, group_joined(gid).sort

      index = kata_manifest(kid)['group_index']
      refute_nil index
      assert index.is_a?(Integer), "index is a #{index.class.name}"
      assert (0..63).include?(index), "!(0..63).include?(#{index})"
      refute avatar_indexes.include?(index), "avatar_indexes.include?(#{index})!"
      avatar_indexes << index
    end
    refute_equal (0..63).to_a, avatar_indexes
    assert_equal (0..63).to_a, avatar_indexes.sort
    assert_nil group_join(gid, indexes)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'group_joined returns nil when the id does not exist' do
    assert_nil group_joined('B4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D5',
  'group_joined information can be retrieved' do
    gid = stub_group_create('58k563')
    kids = group_joined(gid)
    expected = []
    assert_equal(expected, kids, 'someone has already joined!')
    (1..4).to_a.each do |n|
      kid = group_join(gid, indexes)
      expected << kid
      kids = group_joined(gid)
      assert kids.is_a?(Array), "kids is a #{kids.class.name}!"
      assert_equal n, kids.size, 'incorrect size!'
      assert_equal expected.sort, kids.sort, 'does not round-trip!'
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # group_events
  #- - - - - - - - - - - - - - - - - - - - - -

  test 'A04', %w(
  group_events returns null when the id does not exist ) do
      assert_nil group_events('B4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test 'A05', %w(
  group_events is a BatchMethod for web's dashboard ) do
    gid = stub_group_create('e8ArPs')
    kid1 = group_join(gid, indexes)
    index1 = kata_manifest(kid1)['group_index']
    kid2 = group_join(gid, indexes)
    index2 = kata_manifest(kid2)['group_index']
    kata_ran_tests(*make_ran_test_args(kid1, 1, edited_files))

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
    actual = group_events(gid)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test 'A06', %w( test speed of alternative implementations ) do
    one = '{"s":23,"t":[1,2,3,4],"u":"blah"}'
    all = ([one] * 142).join("\n")
    _,slower = timed {
      all.lines.map { |line|
        JSON.parse!(line)
      }
    }
    _,faster = timed {
      JSON.parse!('[' + all.lines.join(',') + ']')
    }
    assert faster < slower, "faster:#{faster}, slower:#{slower}"
  end

  private

  def indexes
    (0..63).to_a.shuffle
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    [result,duration]
  end

end
