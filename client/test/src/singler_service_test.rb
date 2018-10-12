require_relative 'test_base'
require 'json'

class SinglerServiceTest < TestBase

  def self.hex_prefix
    '6AB'
  end

  def singler
    saver
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '966',
  %w( malformed id on any method raises ) do
    error = assert_raises { singler.kata_manifest(nil) }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'SaverService', error.service_name
    assert_equal 'kata_manifest', error.method_name
    json = JSON.parse(error.message)
    assert_equal 'ArgumentError', json['class']
    assert_equal 'id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved kata_manifest contains id ) do
    manifest = starter.manifest
    id = singler.kata_create(manifest)
    manifest['id'] = id
    assert_equal manifest, singler.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after kata_create() then
  and kata_exists?() is true
  and the kata_tags has tag0
  and the kata_manifest can be retrieved ) do
    manifest = starter.manifest
    id = singler.kata_create(manifest)
    assert singler.kata_exists?(id)
    assert_equal([tag0], singler.kata_tags(id))

    files = manifest['visible_files']
    expected = {
      'files' => files,
      'stdout' => '',
      'stderr' => '',
      'status' => 0
    }
    assert_equal expected, singler.kata_tag(id, 0)
    assert_equal expected, singler.kata_tag(id, -1)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A20',
  'kata_ran_tests() returns tags' do
    # This is an optimization to avoid web service
    # having to make a call back to storer to get the
    # tag numbers for the new traffic-light's diff handler.
    id = singler.kata_create(starter.manifest)
    tag1_files = starter.manifest['visible_files']
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    status = 6
    colour = 'amber'
    tags = singler.kata_ran_tests(id, 1, tag1_files, now, stdout, stderr, status, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1}
    ]
    assert_equal expected, tags

    now = [2016,12,5, 21,2,15]
    tags = singler.kata_ran_tests(id, 2, tag1_files, now, stdout, stderr, status, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1},
      {"colour"=>"amber", "time"=>[2016,12,5, 21,2,15], "number"=>2}
    ]
    assert_equal expected, tags
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'kata_ran_tests() with very large file does not raise' do
    # This test fails if docker-compose.yml uses
    # [read_only: true] without also using
    # [tmpfs: /tmp]
    id = singler.kata_create(starter.manifest)

    files = starter.manifest['visible_files']
    files['very_large'] = 'X'*1024*500
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assertion failed'
    status = 41
    colour = 'amber'
    singler.kata_ran_tests(id, 1, files, now, stdout, stderr, status, colour)
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
