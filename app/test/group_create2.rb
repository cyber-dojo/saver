require_relative 'test_base'

class GroupCreate2Test < TestBase

  def self.id58_prefix
    'e08'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  versions3_test 'h35', %w(
  |POST /group_create(manifest)
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  ) do
    assert_json_post_200(
      path = 'group_create',
      { manifest:custom_manifest }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert group_exists?(id), :exists
      assert_equal version, group_manifest(id)['version'], :version
    end
  end

  versions3_test 'h36', %w(
  |POST /group_create(manifest)
  |has status 200
  |returns the id: of a new group
  |that exists in saver
  ) do
    assert_json_post_200(
      path = 'group_create2',
      { manifest:custom_manifest }.to_json
    ) do |response|
      assert_equal [path], response.keys, :keys
      id = response[path]
      assert group_exists?(id), :exists
      assert_equal version, group_manifest(id)['version'], :version
    end
  end

end
