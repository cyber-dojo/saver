# frozen_string_literal: true
require_relative 'test_base'

class ManifestTest < TestBase

  def self.id58_prefix
    '5Ks'
  end

  def id58_setup
    @display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    @custom_manifest = manifest
  end

  attr_reader :display_name, :custom_manifest

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0], '472', %w(
  already existing group_manifest {test-data copied into saver}
  ) do
    manifest = group_manifest(id='chy6BJ')
    refute manifest.has_key?('version')
    assert_equal 'Ruby, MiniTest', manifest['display_name']
    assert_equal 'cyberdojofoundation/ruby_mini_test', manifest['image_name'], :pre_tagging
    assert_equal ['.rb'], manifest['filename_extension']
    assert_equal 2, manifest['tab_size']
    assert_equal [
      "test_hiker.rb",
      "hiker.rb",
      "cyber-dojo.sh",
      "coverage.rb",
      "readme.txt"
    ].sort, manifest['visible_files'].keys.sort
    assert_equal 'Count_Coins', manifest['exercise']
    assert_equal [2019,1,19,12,41,0,406370], manifest['created']
    assert_equal 'chy6BJ', manifest['id']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0], '473', %w(
  already existing kata_manifest {test-data copied into saver}
  is "polyfilled" to make it look like version=1
  ) do
    manifest = kata_manifest(id='5rTJv5')
    refute manifest.has_key?('version')
    assert_equal 'Ruby, MiniTest', manifest['display_name']
    assert_equal 'cyberdojofoundation/ruby_mini_test', manifest['image_name'], :pre_tagging
    assert_equal ['.rb'], manifest['filename_extension']
    assert_equal 2, manifest['tab_size']
    assert_equal 'ISBN', manifest['exercise']
    assert_equal [2019,1,16,12,44,55,800239], manifest['created']
    assert_equal 'FxWwrr', manifest['group_id']
    assert_equal 32, manifest['group_index']
    assert_equal '5rTJv5', manifest['id']
    assert manifest.has_key?('visible_files'), :polyfilled_visible_files
    expected_filenames = [
      "test_hiker.rb",
      "hiker.rb",
      "cyber-dojo.sh",
      "coverage.rb",
      "readme.txt"
    ]
    assert_equal expected_filenames.sort, manifest['visible_files'].keys.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '5s2', %w(
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


  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'Q61', %w(
  retrieved group_manifest matches saved group_manifest
  ) do
    now = [2019,3,17, 7,13,36,3428]
    externals.instance_exec {
      @time = TimeStub.new(now)
    }
    manifest = custom_manifest
    id = group_create(manifest, default_options)
    saved = group_manifest(id)
    manifest.keys.each do |key|
      assert_equal manifest[key], saved[key],  key
    end
    assert saved.keys.include?('created'), :created_key
    assert_equal now, saved['created'], :created
    assert saved.keys.include?('version'), :version_key
    assert_equal version, saved['version'], :version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], 'Q62', %w(
  retrieved kata_manifest matches saved kata_manifest
  ) do
    now = [2018,11,30, 9,34,56,6453]
    externals.instance_exec {
      @time = TimeStub.new(now)
    }
    manifest = custom_manifest
    id = kata_create(manifest, default_options)
    saved = kata_manifest(id)
    manifest.keys.each do |key|
      assert_equal manifest[key], saved[key],  key
    end
    assert saved.keys.include?('created'), :created_key
    assert_equal now, saved['created'], :created
    assert saved.keys.include?('version'), :version_key
    assert_equal version, saved['version'], :version
  end

  private

  class TimeStub
    def initialize(now)
      @now = now
    end
    attr_reader :now
  end

end
