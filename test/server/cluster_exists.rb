require_relative 'test_base'

class ClusterExistsTest < TestBase

  def two_ltf_cluster
    cluster_create('exercise' => 'Tennis', 'ltfs' => [
      manifest_Tennis_refactoring_Python_unitttest,
      manifest_Tennis_refactoring_Ruby_minitest ])
  end

  test 'Ce7b01', %w(
  | cluster_exists? is true for a created cluster
  ) do
    assert cluster_exists?(two_ltf_cluster)
  end

  test 'Ce7b02', %w(
  | cluster_exists? is false for a well-formed id that does not exist
  ) do
    refute cluster_exists?('123AbZ')
  end

  test 'Ce7b03', %w(
  | cluster_exists? is false for a group id or a kata id (neither is a cluster)
  ) do
    cluster_id = two_ltf_cluster
    group_id = cluster_manifest(cluster_id)['children'].first['group_id']
    kata_id  = group_join(group_id)
    refute cluster_exists?(group_id), :group_id_is_not_a_cluster
    refute cluster_exists?(kata_id),  :kata_id_is_not_a_cluster
  end

  test 'Ce7b04', %w(
  | cluster_exists? is false for a malformed id
  ) do
    refute cluster_exists?(42), 'Integer'
    refute cluster_exists?(nil), 'nil'
    refute cluster_exists?([]), '[]'
    refute cluster_exists?({}), '{}'
    refute cluster_exists?(true), 'true'
    refute cluster_exists?(''), 'length == 0'
    refute cluster_exists?('12345'), 'length == 5'
    refute cluster_exists?('12345i'), '!id?()'
  end

  test 'Ce7b05', %w(
  | GET /cluster_exists? is callable and true for a created cluster
  ) do
    cluster_id = two_ltf_cluster
    assert_json_get_200('cluster_exists?', { id: cluster_id }) do |exists|
      assert exists, :cluster_exists
    end
  end

end
