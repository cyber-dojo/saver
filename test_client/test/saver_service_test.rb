require_relative 'test_base'
require 'json'

class SaverServiceTest < TestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha

  test '190',
  %w( sha ) do
    sha = saver.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready

  test '834',
  %w( ready? ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?()

  test '437',
  'exists? is true after write' do
    name = 'groups/1D/F4/37'
    refute saver.exists?(name)
    assert saver.write(name + '/manifest.json', '{}')
    assert saver.exists?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  test '640',
  'write() succeeds when its dir does not already exist' do
    filename = 'groups/1e/94/Aa/readme.md'
    content = 'bonjour'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '641',
  'write() succeeds when its dir exists but its filename does not' do
    filename = 'groups/13/Ff/69/readme.md'
    content = 'greetings'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '642',
  'write() does nothing and returns false when its filename already exists' do
    filename = 'groups/2A/23/Cc/readme.md'
    content = 'welcome'
    assert saver.write(filename, content)
    refute saver.write(filename, content)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  test '841',
  'append() does nothing and returns false when its file does not already exists' do
    filename = 'groups/16/18/59/readme.md'
    content = 'greetings'
    refute saver.append(filename, content)
    assert_nil saver.read(filename)
  end

  test '842',
  'append() appends to the end when its file already exists' do
    filename = 'groups/19/1b/2B/readme.md'
    content = 'helloooo'
    assert saver.write(filename, content)
    assert saver.append(filename, 'more-content')
    assert_equal content+'more-content', saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  test '438',
  'read() reads back what write() writes' do
    filename = 'groups/1D/F4/38/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '439',
  'read() a non-existant file is nil' do
    filename = 'groups/22/23/34/not-there.txt'
    assert_nil saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_read()

  test '440',
  'batch_read() is a read() BatchMethod' do
    dirname = 'groups/14/56/78/'
    there_not = dirname + 'there-not.txt'
    there_yes = dirname + 'there-yes.txt'
    assert saver.write(there_yes, 'content is this')
    reads = saver.batch_read([there_not, there_yes])
    assert_equal [nil,'content is this'], reads
  end

  test '441',
  'batch_read() can read across different sub-dirs' do
    filename1 = 'groups/11/bc/1A/1/kata.id'
    assert saver.write(filename1, 'be30e5')
    filename2 = 'groups/11/bc/1A/14/kata.id'
    assert saver.write(filename2, 'De02CD')
    reads = saver.batch_read([filename1, filename2])
    assert_equal ['be30e5','De02CD'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_false()

  test 'F45',
  'batch_until_false() runs commands until one is false' do
    filename = 'groups/1c/99/48/punchline.txt'
    content = 'thats medeira cake'
    commands = [
      ['write',filename,content],          # true
      ['append',filename,content],         # true
      ['append',filename,content],         # true
      ['write',filename,content]           # false
    ]
    results = saver.batch_until_false(commands)
    assert_equal [true,true,true,false], results
    expected = content * 3
    assert_equal expected, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch_until_true()

  test 'A23',
  'batch_until_true() runs commands until one is true' do
    commands = [
      ['exists?', 'groups/22/34/45'], # false
      ['exists?', 'groups/22/34/67'], # false
      ['write',   'groups/22/34/manifest.json', '{}'], # true
      ['read',    'groups/22/34/manifest.json']        # not processed
    ]
    results = saver.batch_until_true(commands)
    assert_equal [false,false,true], results
  end

=begin
  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # group
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '966',
  %w( malformed id on any method raises ) do
    error = assert_raises(ServiceError) { saver.group_manifest(nil) }
    assert_equal 'SaverService', error.service_name, error
    assert_equal 'group_manifest', error.method_name, error
    json = JSON.parse(error.message)
    assert_equal 'SaverService', json['class'], json
    assert_equal 'malformed:id:!Base58:', json['message'], json
    assert_equal 'Array', json['backtrace'].class.name, json
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
    error = assert_raises(ServiceError) { saver.kata_manifest(nil) }
    assert_equal 'SaverService', error.service_name, error.message
    assert_equal 'kata_manifest', error.method_name, error.message
    json = JSON.parse(error.message)
    assert_equal 'SaverService', json['class'], json
    assert_equal 'malformed:id:!Base58:', json['message'], json
    assert_equal 'Array', json['backtrace'].class.name, json
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
    now = [2016,12,5, 21,1,34,6574]
    duration = 1.67
    stdout = file_form('missing include')
    stderr = file_form('assert failed')
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

    now = [2016,12,5, 21,2,15,564]
    duration = 0.67
    event2_files = event1_files
    event2_files['extra.hpp'] = file_form('#include <stdio.h>')
    stdout = file_form('all tests passed')
    stderr = file_form('')
    status = 0
    colour = 'green'
    saver.kata_ran_tests(id, 2, event2_files, now, duration, stdout, stderr, status, colour)
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
    files['very_large'] = file_form('X'*1024*500)
    now = [2016,12,5, 21,1,34,567]
    duration = 2.56
    stdout = file_form('missing include')
    stderr = file_form('assertion failed')
    status = 41
    colour = 'amber'
    saver.kata_ran_tests(id, 1, files, now, duration, stdout, stderr, status, colour)
  end
=end

  private

  def event0
    {
      'event'  => 'created',
      'time'   => starter.creation_time
    }
  end

  def file_form(content, truncated = false)
    { 'content' => content,
      'truncated' => truncated
    }
  end

end
