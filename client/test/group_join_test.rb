# frozen_string_literal: true
require_relative 'test_base'

class GroupJoinTest < TestBase

  def self.id58_prefix
    'Gw4'
  end

  def id58_setup
    @display_name = custom_start_points.display_names.sample
    manifest = custom_start_points.manifest(display_name)
    manifest['version'] = version
    @custom_manifest = manifest
  end

  attr_reader :display_name, :custom_manifest

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '1s9', %w(
  group is initially empty
  ) do
    manifest = custom_manifest
    id = group_create(manifest, default_options)
    assert_equal({}, joined(id))
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A5', %w(
  when you join a group you increase its size by one,
  and are a member of the group
  ) do
    manifest = custom_manifest
    group_id = group_create(manifest, default_options)

    indexes = [15,4] + ((0..63).to_a - [15,4]).shuffle
    kata_1_id = group_join(group_id, indexes)
    assert kata_exists?(kata_1_id), kata_1_id
    kata_1_manifest = kata_manifest(kata_1_id)
    assert_equal kata_1_id, kata_1_manifest['id']
    assert_equal 15, kata_1_manifest['group_index']
    assert_equal group_id, kata_1_manifest['group_id']

    expected = {}
    expected["15"] = { "id" => kata_1_id }
    assert_equal expected, joined(group_id)

    kata_2_id = group_join(group_id, indexes)
    assert kata_exists?(kata_2_id), kata_2_id
    kata_2_manifest = kata_manifest(kata_2_id)
    assert_equal kata_2_id, kata_2_manifest['id']
    assert_equal 4, kata_2_manifest['group_index']
    assert_equal group_id, kata_2_manifest['group_id']

    expected["4"] = { "id" => kata_2_id }
    assert_equal expected, joined(group_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A6', %w(
  you can join 64 times and then the group is full
  ) do
    #externals.instance_exec { @disk = DiskFake.new }
    manifest = custom_manifest
    group_id = group_create(manifest, default_options)
    expected_ids = []
    64.times do
      kata_id = group_join(group_id)
      refute_nil kata_id, :not_full
      expected_ids << kata_id
    end
    kata_id = group_join(group_id)
    assert_nil kata_id, :full

    expected_indexes = (0..63).to_a
    actual_indexes = joined(group_id).keys.map{|key| key.to_i}
    actual_ids = joined(group_id).values.map{|value| value["id"]}
    assert_equal expected_indexes, actual_indexes.sort
    assert_equal expected_ids.sort, actual_ids.sort
  end

  private

  def joined(id)
    group_joined(id).map{|group_index,v| [group_index,{"id"=>v["id"]}]}.to_h
  end

end
