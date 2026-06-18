require_relative 'test_base'

class ClusterManifestTest < TestBase

  def two_ltf_cluster
    cluster_create('exercise' => 'Tennis', 'ltfs' => [
      manifest_Tennis_refactoring_Python_unitttest,
      manifest_Tennis_refactoring_Ruby_minitest ])
  end

  test 'Cm5d10', %w(
  | cluster_manifest for a well-formed id that does not exist
  | raises a RequestError (HTTP 400 client error)
  | rather than a generic error (HTTP 500 server error)
  ) do
    error = assert_raises(RequestError) { cluster_manifest('123AbZ') }
    assert_equal 'cluster 123AbZ does not exist', error.message
  end

  test 'Cm5d11', %w(
  | cluster_manifest re-raises the original error, rather than masking it as
  | "does not exist", when the cluster exists but its manifest is unreadable.
  | Covers the cluster_exists?==true branch of the rescue.
  ) do
    id = two_ltf_cluster
    path = "/clusters/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/manifest.json"
    disk.run(disk.file_write_command(path, '{ this is not valid json'))
    assert cluster_exists?(id), :cluster_dir_still_exists
    assert_raises(JSON::ParserError) { cluster_manifest(id) }
  end

end
