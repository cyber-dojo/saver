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
    manifest = make_manifest
    id = grouper.create(manifest)
    manifest['id'] = id
    assert_equal manifest, grouper.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  the id can be completed
  and id?() is true
  and the manifest can be retrieved ) do
    id = grouper.create(make_manifest)
    assert grouper.id?(id)
    assert_equal id, grouper.id_completed(id[0..5])
    outer = id[0..1]
    inner = id[2..-1]
    id_completions = grouper.id_completions(outer)
    assert id_completions.include?(outer+inner)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '64E',
  'join succeeds with valid id' do
    id = grouper.create(make_manifest)
    joined = grouper.joined(id)
    assert_equal({}, joined, 'someone has already joined')
    4.times do |n|
      n = n + 1
      index,sid = *grouper.join(id)
      assert index.is_a?(Integer), "#{n}: index is a #{index.class.name}!"
      assert (0..63).include?(index), "#{n}: index(#{index}) not in (0..63)!"
      assert sid.is_a?(String), "#{n}: sid is a #{id.class.name}!"
      joined = grouper.joined(id)
      assert joined.is_a?(Hash), "#{n}: joined is a #{hash.class.name}!"
      assert_equal n, joined.size, "#{n}: incorrect size!"
      diagnostic = "#{n}: #{sid}, #{index}, #{joined}"
      assert_equal sid, joined[index.to_s], diagnostic
    end
  end

  private

  def make_manifest
    manifest = starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

  def creation_time
    [ 2016,12,15, 17,26,34 ]
  end

end
