require_relative 'test_base'
require 'json'

class GrouperServiceTest < TestBase

  def self.hex_prefix
    '6AA1B'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '966',
  %w( malformed id on any method raises ) do
    error = assert_raises { grouper.manifest(nil) }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'GrouperService', error.service_name
    assert_equal 'manifest', error.method_name
    json = JSON.parse(error.message)
    assert_equal 'ArgumentError', json['class']
    assert_equal 'id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190',
  %w( sha ) do
    sha = grouper.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved manifest contains id ) do
    manifest = starter.manifest
    id = grouper.create(manifest, starter.files)
    manifest['id'] = id
    assert_equal manifest, grouper.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '591',
  %w( create(manifest) can pass the id inside the manifest ) do
    manifest = starter.manifest
    explicit_id = '234764'
    manifest['id'] = explicit_id
    id = grouper.create(manifest, starter.files)
    assert_equal explicit_id, id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  id?() is true ) do
    id = grouper.create(starter.manifest, starter.files)
    assert grouper.id?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '64E',
  'join succeeds with valid id' do
    id = grouper.create(starter.manifest, starter.files)
    joined = grouper.joined(id)
    assert_equal({}, joined, 'someone has already joined!')
    indexes = (0..63).to_a.shuffle
    (1..4).to_a.each do |n|
      index,sid = *grouper.join(id, indexes)
      assert index.is_a?(Integer), "#{n}: index is a #{index.class.name}!"
      assert (0..63).include?(index), "#{n}: index(#{index}) not in (0..63)!"
      assert_equal indexes[n-1], index, "#{n}: index is not #{indexes[n-1]}!"
      assert sid.is_a?(String), "#{n}: sid is a #{id.class.name}!"
      joined = grouper.joined(id)
      assert joined.is_a?(Hash), "#{n}: joined is a #{hash.class.name}!"
      assert_equal n, joined.size, "#{n}: incorrect size!"
      diagnostic = "#{n}: #{sid}, #{index}, #{joined}"
      assert_equal sid, joined[index.to_s], diagnostic
    end
  end

end
