require_relative 'test_base'

class KataManifestTest < TestBase

  def self.id58_prefix
    '5Ks'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 0, '473', %w(
  already existing kata_manifest {test-data copied into saver}
  is "polyfilled" to make it look like version=1
  ) do
    manifest = kata_manifest(id='5rTJv5')
    assert_equal 0, manifest['version'], :version
    assert_equal 'Ruby, MiniTest', manifest['display_name'], :display_name
    assert_equal 'cyberdojofoundation/ruby_mini_test', manifest['image_name'], :pre_tagging
    assert_equal ['.rb'], manifest['filename_extension'], :filename_extension
    assert_equal 2, manifest['tab_size'], :tab_size
    assert_equal 'ISBN', manifest['exercise'], :exercise
    assert_equal [2019,1,16, 12,44,55, 800239], manifest['created'], :created
    assert_equal 'FxWwrr', manifest['group_id'], :group_id
    assert_equal 32, manifest['group_index'], :group_index
    assert_equal '5rTJv5', manifest['id'], :id
    assert manifest.has_key?('visible_files'), :polyfilled_visible_files
    expected_filenames = [
      "test_hiker.rb",
      "hiker.rb",
      "cyber-dojo.sh",
      "coverage.rb",
      "readme.txt"
    ]
    assert_equal expected_filenames.sort, manifest['visible_files'].keys.sort, :filenames
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  #TODO: need to find manifests where the optional entries are not present
  versions_test '5s2', %w(
  optional entries are polyfilled ) do
    m = custom_manifest
    m.delete('tab_size')
    m.delete('highlight_filenames')
    assert_equal %w( display_name filename_extension image_name version visible_files ), m.keys.sort
    id = kata_create(m, default_options)
    manifest = kata_manifest(id)
    assert_equal '', manifest['exercise']
    assert_equal [], manifest['highlight_filenames']
    assert_equal  4, manifest['tab_size']
    assert_equal 10, manifest['max_seconds']
    assert_equal [], manifest['progress_regexs']
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'Q62', %w(
  retrieved kata_manifest has created and version keys
  ) do
    now = [2018,11,30, 9,34,56,6453]
    externals.instance_exec {
      @time = TimeStub.new(now)
    }
    in_kata do |id|
      saved = kata_manifest(id)
      assert saved.keys.include?('created'), :created_key
      assert_equal now, saved['created'], :created
      assert saved.keys.include?('version'), :version_key
      assert_equal version, saved['version'], :version
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  include KataTestData

  version_test 2, 'K8S', %w(
  |kata_manifest
  ) do
    now = [2021,5,31, 10,3,51,6553]
    externals.instance_exec { @time = TimeStub.new(now) }
    display_name = "Tennis refactoring, Python unitttest"
    id = kata_create_custom(version, display_name)
    actual = kata_manifest(id)
    expected = {
      'image_name' => "cyberdojofoundation/python_unittest:b8333d3",
      'display_name' => "Tennis refactoring, Python unitttest",
      'filename_extension' => [".py"],
      'version' => 2,
      'created' => now,
      'exercise' => '',
      'highlight_filenames' => [],
      'id' => id,
      'max_seconds' => 10,
      'progress_regexs' => [],
      'tab_size' => 4
    }
    assert_equal expected, actual
  end

end
