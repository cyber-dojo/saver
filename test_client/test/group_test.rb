require_relative 'test_base'

class GroupTest < TestBase

  def self.hex_prefix
    '974'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '392',
  'exists?(id) is true with id returned from successful create()' do
    id = group.create(starter.manifest)
    assert group.exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(), manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '420',
  'manifest() raises when id does not exist' do
    id = 'A4AB37'
    assert_service_error("id:invalid:#{id}") {
      group.manifest(id)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '42E',
  'create() manifest() round-trip' do
    id = group.create(starter.manifest)
    manifest = starter.manifest
    manifest['id'] = id
    if v_test?(2)
      manifest['version'] = 2
    else
      refute manifest.has_key?('version')
    end
    assert_equal manifest, group.manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [1,2], '42F', %w( <new>
    create() fails if saver.write() fails, eg disk is full
  ) do
    gid = '467uDe'
    externals.instance_exec {
      @id_generator =
        Class.new do
          def initialize(id); @id = id; end
          def id; @id; end
        end.new(gid)
      @saver =
        Class.new do
          def create(_key); true; end
          def write(_key,_value); false; end
        end.new
    }
    assert_service_error("id:invalid:#{gid}") {
      group.create(starter.manifest)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # join(), joined()
  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '1D0',
  'join() raises when id does not exist' do
    id = 'A4AB37'
    assert_service_error("id:invalid:#{id}") {
      group.join(id, indexes)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '1D3', %w(
  join() a non-full group with valid id succeeds
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
    if v_test?(2)
      assert_equal 2, manifest['version']
    else
      assert_nil manifest['version']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '1D4', %w(
  join() returns a valid id 64 times
  then its full and it returns nil
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

  v_test [0,1,2], '1D2',
  'joined() returns nil when the id does not exist' do
    assert_nil group.joined('A4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], '1D5',
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

  v_test [0,1,2], 'A04', %w(
  events() returns nil when the id does not exist ) do
      assert_nil group.events('A4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  v_test [0,1,2], 'A05', %w(
  events() is a BatchMethod for web's dashboard ) do
    gid = group.create(starter.manifest)
    kid1 = group.join(gid, indexes)
    index1 = kata.manifest(kid1)['group_index']
    kid2 = group.join(gid, indexes)
    index2 = kata.manifest(kid2)['group_index']
    kata.ran_tests(*make_ran_test_args(kid1, 1, edited_files))

    event1 = {
      'colour' => 'red',
      'time' => time_now,
      'duration' => duration
    }
    if v_test?(2)
      event1['index'] = 1
    end
    expected = {
      kid1 => {
        'index' => index1,
        'events' => [event0,event1]
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
