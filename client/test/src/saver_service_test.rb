require_relative 'test_base'
require 'json'

class SaverServiceTest < TestBase

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
    assert_equal 'SaverService', json['class']
    assert_equal 'malformed:id:!Base58:', json['message']
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
  'group_join succeeds with valid kata-id' do
    gid = saver.group_create(starter.manifest)
    joined = saver.group_joined(gid)
    expected = []
    assert_equal(expected, joined, 'someone has already joined!')
    indexes = (0..63).to_a.shuffle
    (1..4).to_a.each do |n|
      kid = saver.group_join(gid, indexes)
      refute_nil kid
      assert kid.is_a?(String), "kid is a #{kid.class.name}"
      assert_equal 6, kid.size

      index = saver.kata_manifest(kid)['group_index']
      assert index.is_a?(Integer), "#{n}: index is a #{index.class.name}!"
      assert (0..63).include?(index), "#{n}: index(#{index}) not in (0..63)!"
      assert_equal indexes[n-1], index, "#{n}: index is not #{indexes[n-1]}!"

      joined = saver.group_joined(gid)
      assert joined.is_a?(Array), "#{n}: joined is a #{joined.class.name}!"
      assert_equal n, joined.size, "#{n}: incorrect size!"
      diagnostic = "#{n}: #{kid}, #{index}, #{joined}"
      expected << kid
      assert_equal expected.sort, joined.sort, diagnostic
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
    assert_equal 'SaverService', json['class']
    assert_equal 'malformed:id:!Base58:', json['message']
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
  and the kata_events has event0
  and the kata_manifest can be retrieved ) do
    manifest = starter.manifest
    id = saver.kata_create(manifest)
    assert saver.kata_exists?(id)
    assert_equal([event0], saver.kata_events(id))

    files = manifest['visible_files']
    expected = { 'files' => files }
    assert_equal expected, saver.kata_event(id, 0)
    assert_equal expected, saver.kata_event(id, -1)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '820', %w(
  kata_ran_tests() returns nothing
  ) do
    id = saver.kata_create(starter.manifest)
    event1_files = starter.manifest['visible_files']
    event1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    duration = 1.67
    stdout = 'missing include'
    stderr = 'assert failed'
    status = 6
    colour = 'amber'
    result = saver.kata_ran_tests(id, 1, event1_files, now, duration, stdout, stderr, status, colour)
    assert_nil result

    expected_events = [
      event0,
      { 'colour' => 'amber', 'time' => now, 'duration' => duration }
    ]
    assert_equal expected_events, saver.kata_events(id)
    assert_equal({
      'files' => event1_files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
      }, saver.kata_event(id, 1))

    now = [2016,12,5, 21,2,15]
    duration = 0.67
    event2_files = event1_files
    event2_files['extra.hpp'] = '#include <stdio.h>'
    stdout = 'all tests passed'
    stderr = ''
    status = 0
    colour = 'green'
    events = saver.kata_ran_tests(id, 2, event2_files, now, duration, stdout, stderr, status, colour)
    expected_events <<
       { 'colour' => 'green', 'time' => now, 'duration' => duration }
    assert_equal expected_events, saver.kata_events(id)
    assert_equal({
      'files' => event2_files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
      }, saver.kata_event(id, 2))
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
    duration = 2.56
    stdout = 'missing include'
    stderr = 'assertion failed'
    status = 41
    colour = 'amber'
    saver.kata_ran_tests(id, 1, files, now, duration, stdout, stderr, status, colour)
  end

  private

  def event0
    {
      'event'  => 'created',
      'time'   => starter.creation_time
    }
  end

end
