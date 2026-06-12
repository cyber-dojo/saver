require_relative 'test_base'

class ClusterCreateTest < TestBase

  test 'Cl9a30', %w(
  | POST /cluster_create(manifest) creates one child group per ltf (each an
  | ordinary Group_v2 carrying cluster_id) and stores a cluster referencing them;
  | round-trips exercise + children via cluster_manifest
  ) do
    manifest = {
      'exercise' => 'Tennis',
      'ltfs' => [
        manifest_Tennis_refactoring_Python_unitttest,
        manifest_Tennis_refactoring_Ruby_minitest
      ]
    }
    assert_json_post_200(
      path = 'cluster_create',
      { manifest:manifest }.to_json
    ) do |response|
      id = response[path]
      cluster = cluster_manifest(id)
      assert_equal 'Tennis', cluster['exercise'], :exercise
      assert_equal ['Tennis refactoring, Python unitttest',
                    'Tennis refactoring, Ruby minitest'],
                   cluster['children'].map { |c| c['ltf_display_name'] }, :ltf_display_names
      cluster['children'].each do |c|
        assert group_exists?(c['group_id']), c['group_id']
        assert_equal id, group_manifest(c['group_id'])['cluster_id'], :cluster_id
      end
    end
  end

  test 'Cl9a31', %w(
  | POST /cluster_create(manifest) with only one ltf is a 400
  | a single-LTF practice is a bare Group_v2, not a cluster
  ) do
    manifest = {
      'exercise' => 'Tennis',
      'ltfs' => [ manifest_Tennis_refactoring_Python_unitttest ]
    }
    capture_stdout_stderr {
      post_json '/cluster_create', { manifest:manifest }.to_json
    }
    assert_equal 400, last_response.status
  end

  test 'Cl9a32', %w(
  | POST /cluster_create(manifest) with more than 4 ltfs is a 400
  | a cluster offers at most 4 LTFs
  ) do
    manifest = {
      'exercise' => 'Tennis',
      'ltfs' => [
        { 'display_name' => 'C, assert' },
        { 'display_name' => 'Java, JUnit' },
        { 'display_name' => 'Go, testing' },
        { 'display_name' => 'Python, unittest' },
        { 'display_name' => 'Ruby, minitest' }
      ]
    }
    capture_stdout_stderr {
      post_json '/cluster_create', { manifest:manifest }.to_json
    }
    assert_equal 400, last_response.status
  end

end
