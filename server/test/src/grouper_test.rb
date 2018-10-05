require_relative 'test_base'
require_relative 'id_generator_stub'

class GrouperTest < TestBase

  def self.hex_prefix
    '97431'
  end

  def hex_setup
    @real_id_generator = externals.id_generator
    @stub_id_generator = IdGeneratorStub.new
    externals.id_generator = @stub_id_generator
  end

  def hex_teardown
    externals.id_generator = @real_id_generator
  end

  attr_reader :stub_id_generator

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190', %w( sha of image's git commit ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # path
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '218', %w(
  grouper's path is set
  but in test its volume-mounted to /tmp
  so its emphemeral ) do
    assert_equal '/grouper/ids', grouper.path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(manifest) manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '420',
  'manifest raises when id does not exist' do
    id = 'B4AB376BE2'
    error = assert_raises(ArgumentError) {
      manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'create() manifest() round-trip' do
    stub_id = '0ADDE7572A'
    stub_id_generator.stub(stub_id)
    expected = starter.manifest
    id = create(expected, starter.files)
    assert_equal stub_id, id
    expected['id'] = id
    actual = manifest(id)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '422', %w(
  create(manifest) can be passed the id
  and when it is uniquely-completable at 6-chars it is used ) do
    explicit_id = 'CE2BD61EB2'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    externals.id_generator = @real_id_generator
    id = create(manifest, starter.files)
    assert_equal explicit_id, id
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '423', %w(
  create(manifest) can be passed the id
  and raises when it is not uniquely-completeable at c-chars ) do
    stub_id = 'A01DE86620'
    stub_id_generator.stub(stub_id)
    expected = starter.manifest
    id = create(expected, starter.files)

    externals.id_generator = @real_id_generator
    explicit_id = stub_id[0..5]+'1234'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    error = assert_raises(ArgumentError) {
      create(manifest, starter.files)
    }
    assert_equal "id:invalid:#{explicit_id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id?(id), id_completed(partial_id), id_completions(outer_id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'id? is false before creation, true after creation' do
    stub_id = '50C8C661CD'
    refute id?(stub_id)
    stub_create(stub_id)
    assert id?(stub_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '393',
  'id_completed returns id when unique completion' do
    id = stub_create('E4ABB48CA4')
    partial_id = id[0...6]
    assert_equal id, id_completed(partial_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '394',
  'id_completed returns empty-string when no completion' do
    partial_id = 'AC9A0215C9'
    assert_equal '', id_completed(partial_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '395',
  'id_completed returns empty-string when no unique completion' do
    stub_id = '9504E6559'
    stub_create(stub_id + '0')
    stub_create(stub_id + '1')
    partial_id = stub_id[0...6]
    assert_equal '', id_completed(partial_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '396',
  'id_completions when no completions' do
    outer_id = '28'
    assert_equal [], id_completions(outer_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '397',
  'id_completions when a single completion' do
    id = stub_create('7CA8A87A2B')
    outer_id = id[0...2]
    assert_equal [id], id_completions(outer_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '398',
  'id_completions when two completions' do
    outer_id = '22'
    id0 = outer_id + '0' + '3D2DF43'
    id1 = outer_id + '1' + '3D2DF43'
    stub_create(id0)
    stub_create(id1)
    assert_equal [id0,id1].sort, id_completions(outer_id).sort
  end

  #- - - - - - - - - - - - - - - - - - - - - -
  # join/joined
  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D0',
  'join raises when id does not exist' do
    id = 'B4AB376BE2'
    error = assert_raises(ArgumentError) {
      join(id, indexes)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'joined raises when id does not exist' do
    id = 'B4AB376BE2'
    error = assert_raises(ArgumentError) {
      joined(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D3', %w(
  join with valid id succeeds and
  manifest of joined participant contains group id ) do
    stub_id = stub_create('E9r17F3ED8')
    shuffled = indexes
    index,id = *join(stub_id, shuffled)
    assert_equal shuffled[0], index
    manifest = singler.manifest(id)
    assert_equal stub_id, manifest['group']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D4',
  'join with a valid id succeeds 64 times then fails with nil' do
    stub_id = stub_create('D47983B964')
    joined = []
    64.times do
      index,id = *join(stub_id, indexes)
      assert index.is_a?(Integer), "index is a #{index.class.name}!"
      assert (0..63).include?(index), "index(#{index}) not in (0..63)!"
      assert id.is_a?(String), "id is a #{id.class.name}!"
      assert singler.id?(id), "!singler.id?(#{id})"
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
    stub_id = stub_create('58A5639933')
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
