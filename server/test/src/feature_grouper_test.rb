require_relative 'test_base'
require_relative 'id_generator_stub'

class FeatureGrouperTest < TestBase

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

  test '190', %w( sha is exposed via API ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # path
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '218',
  'path is set but in test there is no volume-mount so its emphemeral' do
    assert_equal '/persistent-dir/ids', grouper.path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(manifest) manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42D',
  'manifest raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      manifest('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'manifest round-trip' do
    stub_id = '0ADDE7572A'
    stub_id_generator.stub(stub_id)
    expected = create_manifest
    id = create(expected)
    assert_equal stub_id, id
    expected['id'] = id
    actual = manifest(id)
    assert_equal expected, actual
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
  # join
  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D1',
  'join raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      join('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '1D2',
  'joined raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      joined('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -



  private

  def stub_create(stub_id)
    stub_id_generator.stub(stub_id)
    id = create(create_manifest)
    assert_equal stub_id, id
    id
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def assert_visible_files(expected, actual, output, diagnostic)
    assert actual.keys.include?('output'), diagnostic + ' [output]'
    assert_equal output, actual['output']
    expected.each do |filename,content|
      assert_equal content, actual[filename], diagnostic + " [#{filename}]"
    end
  end

end