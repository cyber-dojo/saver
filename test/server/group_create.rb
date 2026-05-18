require_relative 'test_base'

class GroupCreateTest < TestBase

  version_test 2, 'e08h35', %w(
  | POST /group_create(manifest)
  | has status 200
  | returns the id: of a new group
  | that exists in saver
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

  versions_01_test 'e08h36', %w(
  | POST /group_create(manifest)
  | has status 505 on v0/v1
  ) do
    capture_stdout_stderr {
      post_json '/group_create', { manifest:custom_manifest }.to_json
    }
    assert_equal 505, last_response.status
  end

end
