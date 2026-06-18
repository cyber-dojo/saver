require_relative 'test_base'

class ClusterHierarchyTest < TestBase

  def two_ltf_cluster
    cluster_create('exercise' => 'Tennis', 'ltfs' => [
      manifest_Tennis_refactoring_Python_unitttest,
      manifest_Tennis_refactoring_Ruby_minitest ])
  end

  test 'Hy1a01', %w( | solo kata -> [kata] ) do
    in_kata do |kata_id|
      assert_equal([{ 'type' => 'kata', 'id' => kata_id }], cluster_hierarchy(kata_id))
    end
  end

  test 'Hy1a02', %w( | kata in a bare group -> [kata, group] ) do
    in_group do |group_id|
      kata_id = group_join(group_id)
      assert_equal([{ 'type' => 'kata',  'id' => kata_id },
                    { 'type' => 'group', 'id' => group_id }], cluster_hierarchy(kata_id))
    end
  end

  test 'Hy1a03', %w( | kata in a cluster -> [kata, group, cluster] ) do
    cluster_id = two_ltf_cluster
    group_id = cluster_manifest(cluster_id)['children'].first['group_id']
    kata_id = group_join(group_id)
    assert_equal([{ 'type' => 'kata',    'id' => kata_id },
                  { 'type' => 'group',   'id' => group_id },
                  { 'type' => 'cluster', 'id' => cluster_id }], cluster_hierarchy(kata_id))
  end

  test 'Hy1a04', %w( | bare group -> [group] ) do
    in_group do |group_id|
      assert_equal([{ 'type' => 'group', 'id' => group_id }], cluster_hierarchy(group_id))
    end
  end

  test 'Hy1a05', %w( | group in a cluster -> [group, cluster] ) do
    cluster_id = two_ltf_cluster
    group_id = cluster_manifest(cluster_id)['children'].first['group_id']
    assert_equal([{ 'type' => 'group',   'id' => group_id },
                  { 'type' => 'cluster', 'id' => cluster_id }], cluster_hierarchy(group_id))
  end

  test 'Hy1a06', %w( | cluster -> [cluster] ) do
    cluster_id = two_ltf_cluster
    assert_equal([{ 'type' => 'cluster', 'id' => cluster_id }], cluster_hierarchy(cluster_id))
  end

  versions_01_test 'Hy1a07', %w(
  | a v0/v1 kata in a group -> [kata, group] (no cluster)
  ) do
    katas  = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    groups = { 0 => 'chy6BJ', 1 => 'LyQpFr' }
    kata_id  = katas[version]
    group_id = groups[version]
    assert_equal([{ 'type' => 'kata',  'id' => kata_id },
                  { 'type' => 'group', 'id' => group_id }], cluster_hierarchy(kata_id))
  end

  versions_01_test 'Hy1a08', %w(
  | a v0/v1 bare group -> [group] (no cluster)
  ) do
    groups = { 0 => 'FxWwrr', 1 => 'REf1t8' }
    group_id = groups[version]
    assert_equal([{ 'type' => 'group', 'id' => group_id }], cluster_hierarchy(group_id))
  end

  test 'Hy1a09', %w(
  | a v1 solo kata (not in a group) -> [kata]
  ) do
    kata_id = 'H8NAvN'
    assert_equal([{ 'type' => 'kata', 'id' => kata_id }], cluster_hierarchy(kata_id))
  end

  test 'Hy1a10', %w(
  | GET /cluster_hierarchy(id) returns the id chain for the given id
  ) do
    cluster_id = two_ltf_cluster
    group_id = cluster_manifest(cluster_id)['children'].first['group_id']
    kata_id = group_join(group_id)
    assert_json_get_200('cluster_hierarchy', { id: kata_id }) do |chain|
      assert_equal([{ 'type' => 'kata',    'id' => kata_id },
                    { 'type' => 'group',   'id' => group_id },
                    { 'type' => 'cluster', 'id' => cluster_id }], chain)
    end
  end

  test 'Hy1a11', %w(
  | cluster_hierarchy for a well-formed id that does not exist
  | raises a RequestError (HTTP 400 client error)
  | rather than returning [] (an id matching no kata, group or cluster
  | is a client error, not an empty hierarchy)
  ) do
    error = assert_raises(RequestError) { cluster_hierarchy('123AbZ') }
    assert_equal 'id 123AbZ does not exist', error.message
  end

end
