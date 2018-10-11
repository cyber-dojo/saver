require_relative 'test_base'

class GrouperTest < TestBase

  def self.hex_prefix
    '974'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190', %w( sha of image's git commit ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
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

  test '421',
  'group_create() generates id if one is not supplied' do
    manifest = starter.manifest
    manifest['files'] = starter.files
    refute manifest.key?('id')
    id = group_create(manifest)
    assert manifest.key?('id')
    assert_equal id, manifest['id']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42C', %w(
  kata_create() does NOT raise when the id is provided
  and contains the letter L (ell, lowercase or uppercase)
  (this is for backward compatibility; katas in storer
  have ids with ells and I want porter to have to only map
  ids that are not unique in their first 6 characters)
  ) do
    manifest = starter.manifest
    manifest['files'] = starter.files
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
    manifest['files'] = starter.files
    manifest['id'] = explicit_id
    id = group_create(manifest)
    assert_equal explicit_id, id
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '423', %w(
  group_create(manifest) can be passed the id
  and raises when a group with that id already exists ) do
    explicit_id = 'A01DE8'
    manifest = starter.manifest
    manifest['files'] = starter.files
    manifest['id'] = explicit_id
    id = group_create(manifest)
    assert_equal explicit_id, id

    manifest = starter.manifest
    manifest['files'] = starter.files
    manifest['id'] = id
    error = assert_raises(ArgumentError) {
      group_create(manifest)
    }
    assert_equal "id:invalid:#{id}", error.message
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
    m['files'] = starter.files
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
  group_join with valid id succeeds and
  manifest of joined participant contains group id ) do
    stub_id = stub_group_create('E9r17F')
    shuffled = indexes
    index,id = group_join(stub_id, shuffled)
    assert_equal shuffled[0], index
    manifest = singler.kata_manifest(id)
    assert_equal stub_id, manifest['group']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D4',
  'group_join with a valid id succeeds 64 times then fails with nil' do
    stub_id = stub_group_create('D47983')
    joined = []
    64.times do
      index,id = *group_join(stub_id, indexes)
      assert index.is_a?(Integer), "index is a #{index.class.name}!"
      assert (0..63).include?(index), "index(#{index}) not in (0..63)!"
      assert id.is_a?(String), "id is a #{id.class.name}!"
      assert singler.kata_exists?(id), "!singler.kata_exists?(#{id})"
      refute joined.include?(index), "joined.include?(#{index})!"
      joined << index
    end
    refute_equal (0..63).to_a, joined
    assert_equal (0..63).to_a, joined.sort
    n = group_join(stub_id, indexes)
    assert_nil n
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'group_joined returns nil when the id does not exist' do
    assert_nil group_joined('B4AB37')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D5',
  'group_joined information can be retrieved' do
    stub_id = stub_group_create('58A563')
    hash = group_joined(stub_id)
    assert_equal({}, hash, 'someone has already joined!')
    (1..4).to_a.each do |n|
      index,sid = group_join(stub_id, indexes)
      hash = group_joined(stub_id)
      assert hash.is_a?(Hash), "hash is a #{hash.class.name}!"
      assert_equal n, hash.size, 'incorrect size!'
      assert_equal sid, hash[index], 'does not round-trip!'
    end
  end

  private

  def indexes
    (0..63).to_a.shuffle
  end

  def singler
    externals.singler
  end

end
