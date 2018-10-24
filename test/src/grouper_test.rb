require_relative 'test_base'

class GrouperTest < TestBase

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

  class StubDisk
    def [](_name)
      self
    end
    def exists?
      false
    end
    def make
      false
    end
  end
  class StubExternals
    def grouper
      Grouper.new(self)
    end
    def storer
      StorerService.new
    end
    def disk
      StubDisk.new
    end
    def id_validator
      IdValidator.new(self)
    end
  end

  test '42F', %w(
  group_create raises when id's dir cannot be created
  ) do
    grouper = StubExternals.new.grouper
    error = assert_raises(ArgumentError) {
      grouper.group_create(starter.manifest)
    }
    assert error.message.start_with?('id:invalid'), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'group_create() generates id if one is not supplied' do
    manifest = starter.manifest
    refute manifest.key?('id')
    id = group_create(manifest)
    assert manifest.key?('id')
    assert_equal id, manifest['id']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42C', %w(
  kata_create() does NOT raise when the id is provided
  and contains the letter L (ell, lowercase or uppercase)
  (this is for backwards compatibility; katas in storer
  have ids with ells and I want porter to have to only map
  ids that are not unique in their first 6 characters)
  ) do
    manifest = starter.manifest
    ell = 'L'

    id = '12345' + ell.upcase
    manifest['id'] = id
    assert_equal id, group_create(manifest)

    id = '12345' + ell.downcase
    manifest['id'] = id
    assert_equal id, group_create(manifest)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '422', %w(
  group_create(manifest) can be passed the id
  and its used when a group with that id does not already exist ) do
    explicit_id = 'CE2BD6'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = group_create(manifest)
    assert_equal explicit_id, id
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '423', %w(
  group_create(manifest) can be passed the id
  and raises when a saver group with that id already exists ) do
    explicit_id = 'A01DE8'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = group_create(manifest)
    assert_equal explicit_id, id

    manifest = starter.manifest
    manifest['id'] = id
    error = assert_raises(ArgumentError) {
      group_create(manifest)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '424', %w(
  group_create(manifest) can be passed the id
  and uses that id when a storer practice session with that id already exists
  since it is assumed porter is porting that session
  ) do
    storer_id = '5A0F824303'[0..5]
    manifest = starter.manifest
    manifest['id'] = storer_id
    id = group_create(manifest)
    assert_equal id, storer_id
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
    id = '0ADDE7'
    m = starter.manifest
    m['id'] = id
    group_create(m)
    assert_equal m, group_manifest(id)
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
  and the manifest of joined participant contains
  the group id and the avatar index ) do
    stub_id = stub_group_create('E9r17F')
    shuffled = indexes
    kid = group_join(stub_id, shuffled)
    manifest = singler.kata_manifest(kid)
    assert_equal stub_id, manifest['group']
    assert_equal shuffled[0], manifest['index']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D4', %w(
  group_join with a valid id succeeds 64 times
  then its full and it fails with nil
  ) do
    stub_id = stub_group_create('z47983')
    joined = []
    64.times do
      kid = group_join(stub_id, indexes)
      assert kid.is_a?(String), "kid is a #{kid.class.name}!"
      assert singler.kata_exists?(kid), "!singler.kata_exists?(#{kid})"
      index = singler.kata_manifest(kid)['index']
      refute joined.include?(index), "joined.include?(#{index})!"
      joined << index
    end
    refute_equal (0..63).to_a, joined
    assert_equal (0..63).to_a, joined.sort
    assert_nil group_join(stub_id, indexes)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'group_joined returns nil when the id does not exist' do
    assert_nil group_joined('B4aB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D5',
  'group_joined information can be retrieved' do
    stub_id = stub_group_create('58k563')
    hash = group_joined(stub_id)
    assert_equal({}, hash, 'someone has already joined!')
    (1..4).to_a.each do |n|
      kid = group_join(stub_id, indexes)
      index = singler.kata_manifest(kid)['index']
      hash = group_joined(stub_id)
      assert hash.is_a?(Hash), "hash is a #{hash.class.name}!"
      assert_equal n, hash.size, 'incorrect size!'
      assert_equal kid, hash[index], 'does not round-trip!'
    end
  end

  private

  def indexes
    (0..63).to_a.shuffle
  end

end
