require_relative 'test_base'
require 'json'

class GrouperServiceTest < TestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190',
  %w( sha ) do
    sha = saver.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # group
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '966',
  %w( malformed id on any method raises ) do
    error = assert_raises { saver.group_manifest(nil) }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'SaverService', error.service_name
    assert_equal 'group_manifest', error.method_name
    json = JSON.parse(error.message)
    assert_equal 'ArgumentError', json['class']
    assert_equal 'id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved group_manifest contains id ) do
    manifest = starter.manifest
    id = saver.group_create(manifest)
    manifest['id'] = id
    assert_equal manifest, saver.group_manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '591',
  %w( group_create(manifest) can pass the id inside the manifest ) do
    manifest = starter.manifest
    explicit_id = '64DDD3'
    manifest['id'] = explicit_id
    id = saver.group_create(manifest)
    assert_equal explicit_id, id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after group_create() then
  group_exists?() is true ) do
    id = saver.group_create(starter.manifest)
    assert saver.group_exists?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '64E',
  'group_join succeeds with valid id' do
    id = saver.group_create(starter.manifest)
    joined = saver.group_joined(id)
    assert_equal({}, joined, 'someone has already joined!')
    indexes = (0..63).to_a.shuffle
    (1..4).to_a.each do |n|
      index,sid = *saver.group_join(id, indexes)
      assert index.is_a?(Integer), "#{n}: index is a #{index.class.name}!"
      assert (0..63).include?(index), "#{n}: index(#{index}) not in (0..63)!"
      assert_equal indexes[n-1], index, "#{n}: index is not #{indexes[n-1]}!"
      assert sid.is_a?(String), "#{n}: sid is a #{id.class.name}!"
      joined = saver.group_joined(id)
      assert joined.is_a?(Hash), "#{n}: joined is a #{hash.class.name}!"
      assert_equal n, joined.size, "#{n}: incorrect size!"
      diagnostic = "#{n}: #{sid}, #{index}, #{joined}"
      assert_equal sid, joined[index.to_s], diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '866',
  %w( malformed id on any method raises ) do
    error = assert_raises { saver.kata_manifest(nil) }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'SaverService', error.service_name
    assert_equal 'kata_manifest', error.method_name
    json = JSON.parse(error.message)
    assert_equal 'ArgumentError', json['class']
    assert_equal 'id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8E7',
  %w( retrieved kata_manifest contains id ) do
    manifest = starter.manifest
    id = saver.kata_create(manifest)
    manifest['id'] = id
    assert_equal manifest, saver.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8F9', %w(
  after kata_create() then
  and kata_exists?() is true
  and the kata_tags has tag0
  and the kata_manifest can be retrieved ) do
    manifest = starter.manifest
    id = saver.kata_create(manifest)
    assert saver.kata_exists?(id)
    assert_equal([tag0], saver.kata_tags(id))

    files = manifest['visible_files']
    expected = {
      'files' => files,
      'stdout' => '',
      'stderr' => '',
      'status' => 0
    }
    assert_equal expected, saver.kata_tag(id, 0)
    assert_equal expected, saver.kata_tag(id, -1)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '820',
  'kata_ran_tests() returns tags' do
    # This is an optimization to avoid web service
    # having to make a call back to storer to get the
    # tag numbers for the new traffic-light's diff handler.
    id = saver.kata_create(starter.manifest)
    tag1_files = starter.manifest['visible_files']
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    status = 6
    colour = 'amber'
    tags = saver.kata_ran_tests(id, 1, tag1_files, now, stdout, stderr, status, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1}
    ]
    assert_equal expected, tags

    now = [2016,12,5, 21,2,15]
    tags = saver.kata_ran_tests(id, 2, tag1_files, now, stdout, stderr, status, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1},
      {"colour"=>"amber", "time"=>[2016,12,5, 21,2,15], "number"=>2}
    ]
    assert_equal expected, tags
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '822',
  'kata_ran_tests() with very large file does not raise' do
    # This test fails if docker-compose.yml uses
    # [read_only: true] without also using
    # [tmpfs: /tmp]
    id = saver.kata_create(starter.manifest)

    files = starter.manifest['visible_files']
    files['very_large'] = 'X'*1024*500
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assertion failed'
    status = 41
    colour = 'amber'
    saver.kata_ran_tests(id, 1, files, now, stdout, stderr, status, colour)
  end

  private

  def tag0
    {
      'event'  => 'created',
      'time'   => starter.creation_time,
      'number' => 0
    }
  end

end
