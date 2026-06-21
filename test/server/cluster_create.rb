require_relative 'test_base'

class ClusterCreateTest < TestBase

  test 'Cl9a30', %w(
  | POST /cluster_create(manifests) creates one child group per ltf (each an
  | ordinary Group_v2 carrying cluster_id) and stores a cluster whose groups map
  | each group_id to its manifest; round-trips groups via cluster_manifest
  ) do
    manifests = [
      manifest_Tennis_refactoring_Python_unitttest,
      manifest_Tennis_refactoring_Ruby_minitest
    ]
    assert_json_post_200(
      path = 'cluster_create',
      { manifests:manifests }.to_json
    ) do |response|
      id = response[path]
      cluster = cluster_manifest(id)
      assert_equal ['Tennis refactoring, Python unitttest',
                    'Tennis refactoring, Ruby minitest'],
                   cluster['groups'].values.map { |m| m['display_name'] }, :display_names
      cluster['groups'].each do |group_id, manifest|
        assert group_exists?(group_id), group_id
        assert_equal id, group_manifest(group_id)['cluster_id'], :cluster_id
        assert_equal manifest['display_name'],
                     group_manifest(group_id)['display_name'], :group_manifest
      end
    end
  end

  test 'Cl9a31', %w(
  | POST /cluster_create(manifests) with only one ltf is a 400
  | a single-LTF practice is a bare Group_v2, not a cluster
  ) do
    manifests = [ manifest_Tennis_refactoring_Python_unitttest ]
    capture_stdout_stderr {
      post_json '/cluster_create', { manifests:manifests }.to_json
    }
    assert_equal 400, last_response.status
  end

  test 'Cl9a32', %w(
  | POST /cluster_create(manifests) with more than 5 ltfs is a 400
  | a cluster offers at most 5 LTFs
  ) do
    manifests = [
      { 'display_name' => 'C, assert' },
      { 'display_name' => 'Java, JUnit' },
      { 'display_name' => 'Go, testing' },
      { 'display_name' => 'Python, unittest' },
      { 'display_name' => 'Ruby, minitest' },
      { 'display_name' => 'Rust, cargo test' }
    ]
    capture_stdout_stderr {
      post_json '/cluster_create', { manifests:manifests }.to_json
    }
    assert_equal 400, last_response.status
  end

end
