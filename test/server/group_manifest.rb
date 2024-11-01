require_relative 'test_base'

class GroupManifestTest < TestBase

  def self.id58_prefix
    '5Zt'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, '472', %w(
  already existing group_manifest {test-data copied into saver}
  ) do
    manifest = group_manifest(id='chy6BJ')
    assert_equal 0, manifest['version'], :version
    assert_equal 'Ruby, MiniTest', manifest['display_name'], :display_name
    assert_equal 'cyberdojofoundation/ruby_mini_test', manifest['image_name'], :pre_tagging
    assert_equal ['.rb'], manifest['filename_extension'], :filename_extension
    assert_equal 2, manifest['tab_size'], :tab_size
    assert_equal [
      "test_hiker.rb",
      "hiker.rb",
      "cyber-dojo.sh",
      "coverage.rb",
      "readme.txt"
    ].sort, manifest['visible_files'].keys.sort, :filenames
    assert_equal 'Count_Coins', manifest['exercise'], :exercise
    assert_equal [2019,1,19,12,41,0,406370], manifest['created'], :created
    assert_equal 'chy6BJ', manifest['id'], :id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Q61', %w(
  retrieved group_manifest has created and version keys
  ) do
    now = [2019,3,17, 7,13,36,3428]
    externals.instance_exec {
      @time = TimeStub.new(now)
    }
    in_group do |id|
      manifest = group_manifest(id)
      assert manifest.keys.include?('created'), :created_key
      assert_equal now, manifest['created'], :created
      assert manifest.keys.include?('version'), :version_key
      assert_equal version, manifest['version'], :version
    end
  end

end
