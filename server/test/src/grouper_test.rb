require_relative 'test_base'

class GrouperTest < TestBase

  def self.hex_prefix
    '97431'
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
  # create(manifest) manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '420',
  'manifest raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'create() manifest() round-trip' do
    id = '0ADDE7'
    m = starter.manifest
    m['id'] = id
    create(m, starter.files)
    assert_equal m, manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '422', %w(
  create(manifest) can be passed the id
  and its used when a group with that id does not already exist ) do
    explicit_id = 'CE2BD6'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = create(manifest, starter.files)
    assert_equal explicit_id, id
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '423', %w(
  create(manifest) can be passed the id
  and raises when a group with that id already exists ) do
    explicit_id = 'A01DE8'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = create(manifest, starter.files)
    assert_equal explicit_id, id

    manifest = starter.manifest
    manifest['id'] = id
    error = assert_raises(ArgumentError) {
      create(manifest, starter.files)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'exists? is false before creation, true after creation' do
    id = '50C8C6'
    refute exists?(id)
    stub_create(id)
    assert exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # join/joined
  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D0',
  'join raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      join(id, indexes)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'joined raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      joined(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D3', %w(
  join with valid id succeeds and
  manifest of joined participant contains group id ) do
    stub_id = stub_create('E9r17F')
    shuffled = indexes
    index,id = *join(stub_id, shuffled)
    assert_equal shuffled[0], index
    manifest = singler.manifest(id)
    assert_equal stub_id, manifest['group']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D4',
  'join with a valid id succeeds 64 times then fails with nil' do
    stub_id = stub_create('D47983')
    joined = []
    64.times do
      index,id = *join(stub_id, indexes)
      assert index.is_a?(Integer), "index is a #{index.class.name}!"
      assert (0..63).include?(index), "index(#{index}) not in (0..63)!"
      assert id.is_a?(String), "id is a #{id.class.name}!"
      assert singler.exists?(id), "!singler.exists?(#{id})"
      refute joined.include?(index), "joined.include?(#{index})!"
      joined << index
    end
    refute_equal (0..63).to_a, joined
    assert_equal (0..63).to_a, joined.sort
    n = join(stub_id, indexes)
    assert_nil n
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D5',
  'joined information can be retrieved' do
    stub_id = stub_create('58A563')
    hash = joined(stub_id)
    assert_equal({}, hash, 'someone has already joined!')
    (1..4).to_a.each do |n|
      index,sid = *join(stub_id, indexes)
      hash = joined(stub_id)
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
